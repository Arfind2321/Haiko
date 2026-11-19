from txtai import Embeddings
from concurrent import futures

import grpc
import editinginvoke_pb2
import editinginvoke_pb2_grpc
  
        
class Cursor:
    def __init__(self):
        self.embeddings = Embeddings(content=True)
        self.embeddings.load("my_search_index")

    def change_document(self, id, title, parts):
        emb_ids = [part['id'] for part in self.embeddings.search(f"select id from txtai where ArticleId = '{id}'", limit=10000)]
        emb_ids.sort()
        if emb_ids == []:
            self.embeddings.upsert([{"text": title, "ArticleId": id}])
            for part in parts:
                self.embeddings.upsert([{"text": part.Content, "ArticleId": id}])
                self.embeddings.save("my_search_index")
        else:
            self.embeddings.upsert([{"id": emb_ids[0], "text": title, "ArticleId": id}])

            for i, part in enumerate(parts):
                if i + 1 < len(emb_ids):
                    self.embeddings.upsert([{"id": emb_ids[i + 1], "text": part.Content, "ArticleId": id,"PartId": part.Id, "Title": part.Title}])
                    self.embeddings.save("my_search_index")
                else:
                    self.embeddings.upsert([{"text": part.Content, "ArticleId": id, "PartId": part.Id, "Title": part.Title}])
                    self.embeddings.save("my_search_index")


            self.embeddings.save("my_search_index")
    def delete_document(self, id):
        emb_ids = [part['id'] for part in self.embeddings.search(f"select id from txtai where ArticleId = '{id}'", limit=10000)]
        if emb_ids != []:
            self.embeddings.delete(emb_ids)
            self.embeddings.save("my_search_index")



class SearcherDatabase(editinginvoke_pb2_grpc.SearcherDatabase):
    def PushArticleRemoval(self, request, context):
        doc_id = request.ArticleId
        cursor.delete_document(doc_id)

        return editinginvoke_pb2.StatusResponse(isOK=True)

    def PushArticleChanges(self, request, context):
        print(f"Received article changes: {request}")
        doc_id = request.ArticleId
        title = request.Title
        parts = request.Parts
        print(parts[0].Id)

    
        cursor.change_document(doc_id, title, parts)

        return editinginvoke_pb2.StatusResponse(isOK=True)


def start_server():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))

    editinginvoke_pb2_grpc.add_SearcherDatabaseServicer_to_server(
        SearcherDatabase(), server
    )

    server.add_insecure_port(f"[::]:8080")
    server.start()
    server.wait_for_termination()

if __name__ == "__main__":
    cursor = Cursor()
    start_server()