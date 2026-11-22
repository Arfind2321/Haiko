from io import BytesIO
from pathlib import Path
from typing import List

from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
import json

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
)

from xml.sax.saxutils import escape


# ============================================================
# Настройки приложения
# ============================================================

app = FastAPI(
    title="Сервис для генерации PDF-инструкций",
    description="API для создания PDF-файлов с инструкциями",
    version="1.0.0",
)


# ============================================================
# Настройки шрифтов
# ============================================================

BASE_DIR = Path(__file__).resolve().parent
FONTS_DIR = BASE_DIR / "fonts"

REGULAR_FONT_PATH = FONTS_DIR / "DejaVuSans.ttf"
BOLD_FONT_PATH = FONTS_DIR / "DejaVuSans-Bold.ttf"

REGULAR_FONT_NAME = "InstructionFont"
BOLD_FONT_NAME = "InstructionFont-Bold"


def register_fonts() -> None:
    """
    Регистрирует шрифты с поддержкой кириллицы.
    """

    if not REGULAR_FONT_PATH.exists():
        raise FileNotFoundError(
            f"Не найден файл шрифта: {REGULAR_FONT_PATH}"
        )

    if not BOLD_FONT_PATH.exists():
        raise FileNotFoundError(
            f"Не найден файл шрифта: {BOLD_FONT_PATH}"
        )

    pdfmetrics.registerFont(
        TTFont(
            REGULAR_FONT_NAME,
            str(REGULAR_FONT_PATH),
        )
    )

    pdfmetrics.registerFont(
        TTFont(
            BOLD_FONT_NAME,
            str(BOLD_FONT_PATH),
        )
    )


# Регистрируем шрифты при импорте приложения
register_fonts()


# ============================================================
# Pydantic-модели
# ============================================================

class InstructionStep(BaseModel):
    """
    Один шаг инструкции.
    """

    title: str = Field(
        ...,
        min_length=1,
        description="Заголовок шага",
        examples=["Скачайте приложение"],
    )

    body: str = Field(
        ...,
        min_length=1,
        description="Описание шага",
        examples=["Перейдите на официальный сайт и скачайте файл."],
    )


class InstructionRequest(BaseModel):
    """
    Данные для создания PDF-инструкции.
    """

    title: str = Field(
        ...,
        min_length=1,
        description="Заголовок инструкции",
        examples=["Инструкция по установке приложения"],
    )

    steps: List[InstructionStep] = Field(
        ...,
        min_length=1,
        description="Список шагов инструкции",
    )

    filename: str = Field(
        default="instruction.pdf",
        min_length=1,
        description="Имя выходного PDF-файла",
        examples=["installation-guide.pdf"],
    )


# ============================================================
# Вспомогательные функции
# ============================================================

def prepare_text(text: str) -> str:
    """
    Подготавливает текст для вставки в Paragraph ReportLab.

    Поддерживаются:

    \\n  — перенос строки
    \\n\\n — новый абзац
    """

    text = escape(text.strip())

    paragraphs = text.split("\n\n")

    prepared_paragraphs = []

    for paragraph in paragraphs:
        paragraph = paragraph.replace("\n", "<br/>")
        prepared_paragraphs.append(paragraph)

    return "<br/><br/>".join(prepared_paragraphs)


def draw_page_background(canvas, document) -> None:
    """
    Рисует цветной фон страницы.

    Измените значение BACKGROUND_COLOR,
    чтобы выбрать другой цвет.
    """

    canvas.saveState()

    # Цвет фона страницы.
    # Примеры:
    # #FFFFFF — белый
    # #F3F4F6 — светло-серый
    # #EFF6FF — светло-синий
    # #FFF7ED — светло-оранжевый
    # #1F2937 — темно-серый
    BACKGROUND_COLOR = "#1e221c"

    canvas.setFillColor(
        colors.HexColor(BACKGROUND_COLOR)
    )

    page_width, page_height = A4

    # Рисуем прямоугольник на всю страницу
    canvas.rect(
        0,
        0,
        page_width,
        page_height,
        fill=1,
        stroke=0,
    )

    canvas.restoreState()


def draw_page_number(canvas, document) -> None:
    """
    Добавляет номер страницы внизу документа.
    """

    canvas.saveState()

    canvas.setFont(
        REGULAR_FONT_NAME,
        8,
    )

    canvas.setFillColor(
        colors.HexColor("#6B7280")
    )

    page_number = canvas.getPageNumber()

    canvas.drawCentredString(
        A4[0] / 2,
        12 * mm,
        f"Страница {page_number}",
    )

    canvas.restoreState()


def draw_background_and_page_number(canvas, document) -> None:
    """
    Callback, который вызывается для каждой страницы.

    Сначала рисуется фон, затем номер страницы.
    """

    draw_page_background(canvas, document)
    draw_page_number(canvas, document)


def create_pdf(data: InstructionRequest) -> BytesIO:
    """
    Создает PDF в памяти и возвращает BytesIO.
    """

    pdf_buffer = BytesIO()

    document = SimpleDocTemplate(
        pdf_buffer,
        pagesize=A4,

        # Отступы содержимого от краев страницы
        rightMargin=20 * mm,
        leftMargin=20 * mm,
        topMargin=20 * mm,
        bottomMargin=22 * mm,

        title=data.title,
        author="PDF Instruction Service",
    )

    styles = getSampleStyleSheet()

    # Стиль главного заголовка
    title_style = ParagraphStyle(
        name="InstructionTitle",
        parent=styles["Title"],
        fontName=BOLD_FONT_NAME,
        fontSize=24,
        leading=30,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#FFFFFF"),
        spaceAfter=18,
    )

    # Стиль заголовка шага
    step_title_style = ParagraphStyle(
        name="StepTitle",
        parent=styles["Heading2"],
        fontName=BOLD_FONT_NAME,
        fontSize=15,
        leading=20,
        alignment=TA_LEFT,
        textColor=colors.HexColor("#FFFFFF"),
        spaceBefore=10,
        spaceAfter=8,
    )

    # Стиль основного текста
    body_style = ParagraphStyle(
        name="StepBody",
        parent=styles["BodyText"],
        fontName=REGULAR_FONT_NAME,
        fontSize=11,
        leading=17,
        alignment=TA_LEFT,
        textColor=colors.HexColor("#FFFFFF"),
        spaceAfter=12,
    )

    story = []

    # Заголовок инструкции
    story.append(
        Paragraph(
            escape(data.title),
            title_style,
        )
    )

    story.append(
        Spacer(
            1,
            5 * mm,
        )
    )

    # Разделительная линия
    story.append(
        Paragraph(
            '<font color="#FFFFFF">'
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            "</font>",
            body_style,
        )
    )

    story.append(
        Spacer(
            1,
            5 * mm,
        )
    )

    # Вывод шагов
    for index, step in enumerate(data.steps, start=1):
        step_title = f"{index}. {escape(step.title)}"

        story.append(
            Paragraph(
                step_title,
                step_title_style,
            )
        )

        story.append(
            Paragraph(
                prepare_text(step.body),
                body_style,
            )
        )

        # Разделитель между шагами
        if index < len(data.steps):
            story.append(
                Paragraph(
                    '<font color="#FFFFFF">'
                    "────────────────────────────"
                    "</font>",
                    body_style,
                )
            )

    # Создаем PDF
    document.build(
        story,
        onFirstPage=draw_background_and_page_number,
        onLaterPages=draw_background_and_page_number,
    )

    pdf_buffer.seek(0)

    return pdf_buffer


def sanitize_filename(filename: str) -> str:
    """
    Минимально очищает имя файла для HTTP-заголовка.
    """

    filename = filename.strip()

    filename = filename.replace("\r", "")
    filename = filename.replace("\n", "")
    filename = filename.replace('"', "")
    filename = filename.replace("/", "_")
    filename = filename.replace("\\", "_")

    if not filename:
        filename = "instruction.pdf"

    if not filename.lower().endswith(".pdf"):
        filename += ".pdf"

    return filename


# ============================================================
# API endpoints
# ============================================================


@app.get("/instructions/pdf")
def generate_instruction_pdf(data: InstructionRequest):
    """
    Создает PDF-инструкцию и возвращает ее клиенту.
    """

    try:
        pdf_file = create_pdf(data)

    except FileNotFoundError as error:
        raise HTTPException(
            status_code=500,
            detail=str(error),
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Ошибка при создании PDF: {error}",
        )

    filename = sanitize_filename(data.filename)

    return StreamingResponse(
        pdf_file,
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; filename="{filename}"'
            )
        },
    )
'''
@app.get("/instructions/pdf")
def generate_instruction_pdf_get(
    title: str = Query(
        ...,
        min_length=1,
        description="Заголовок инструкции",
    ),
    body: str = Query(
        ...,
        min_length=1,
        description="Текст инструкции",
    ),
    filename: str = Query(
        default="instruction.pdf",
        description="Имя PDF-файла",
    ),
):
    """
    Создает PDF через GET-запрос.

    Пример:

    /instructions/pdf?title=Моя инструкция&body=Текст инструкции
    """

    data = InstructionRequest(
        title=title,
        steps=[
            InstructionStep(
                title="Инструкция",
                body=body,
            )
        ],
        filename=filename,
    )

    try:
        pdf_file = create_pdf(data)

    except FileNotFoundError as error:
        raise HTTPException(
            status_code=500,
            detail=str(error),
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Ошибка при создании PDF: {error}",
        )

    safe_filename = sanitize_filename(filename)

    return StreamingResponse(
        pdf_file,
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; filename="{safe_filename}"'
            )
        },
    )

'''

@app.get("/api/pdf/gen")
def generate_pdf_by_query(
    query: str = Query(
        ...,
        description="JSON с данными инструкции",
    ),
):
    """
    GET /api/pdf/gen?query={...}
    """

    try:
        # Преобразуем JSON-строку в Python-словарь
        query_data = json.loads(query)

        # Проверяем и валидируем данные через Pydantic-модель
        instruction = InstructionRequest(**query_data)

        # Создаем PDF
        pdf_file = create_pdf(instruction)

        # Очищаем имя файла
        filename = sanitize_filename(instruction.filename)

        return StreamingResponse(
            pdf_file,
            media_type="application/pdf",
            headers={
                "Content-Disposition": (
                    f'attachment; filename="{filename}"'
                )
            },
        )

    except json.JSONDecodeError:
        raise HTTPException(
            status_code=400,
            detail="Параметр query содержит некорректный JSON",
        )

    except Exception as error:
        raise HTTPException(
            status_code=400,
            detail=f"Ошибка обработки запроса: {error}",
        )