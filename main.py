from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import openpyxl
from datetime import datetime
import os

app = FastAPI(title="Lift Biznes Serveri")

EXCEL_FILE = "Lift_Sotuvlari.xlsx"

# Excel fayli bo'lmasa, avtomatik yaratish funksiyasi
def init_excel():
    if not os.path.exists(EXCEL_FILE):
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Sotuvlar"
        headers = [
            "Sana", "Sotuvchi", "Mijoz/Ob'ekt", "Lift Parametri", 
            "Zavod Tannarxi ($)", "Montaj ($)", "Karkaz ($)", 
            "Jami Tannarx ($)", "Sotuv Narxi ($)", "Sof Foyda ($)", 
            "Avans ($)", "Qoldiq ($)", "Muddati (Kun)"
        ]
        ws.append(headers)
        wb.save(EXCEL_FILE)

init_excel()

class SaleData(BaseModel):
    seller: str             # Toxirjon, Saidaxmad, Avazbek, Mavlonjon
    client_name: str        # Mijoz nomi / Ob'ekt
    lift_info: str          # Masalan: "7/7/7, 1000kg, DISPECHERLIKLI"
    factory_price: float    # Prayst narxi
    montage_price: float = 1200.0  # Vaqtincha 1200$
    has_karkaz: bool        # True / False
    selling_price: float    # Sotuv narxi
    advance_payment: float  # Avans
    delivery_days: int      # 10, 20, 30 kun

@app.post("/add_sale")
def add_sale(sale: SaleData):
    try:
        wb = openpyxl.load_workbook(EXCEL_FILE)
        ws = wb["Sotuvlar"]
        
        karkaz_price = 1500.0 if sale.has_karkaz else 0.0
        total_cost = sale.factory_price + sale.montage_price + karkaz_price
        profit = sale.selling_price - total_cost
        remaining_balance = sale.selling_price - sale.advance_payment
        current_date = datetime.now().strftime("%d.%m.%Y %H:%M")
        
        new_row = [
            current_date,
            sale.seller,
            sale.client_name,
            sale.lift_info,
            sale.factory_price,
            sale.montage_price,
            karkaz_price,
            total_cost,
            sale.selling_price,
            profit,
            sale.advance_payment,
            remaining_balance,
            f"{sale.delivery_days} KUN"
        ]
        ws.append(new_row)
        wb.save(EXCEL_FILE)
        
        return {"status": "success", "message": "Sotuv Excel fayliga saqlandi!", "profit": profit}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))