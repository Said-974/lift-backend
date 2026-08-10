from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime

app = FastAPI(title="SPACE-S Lift Serveri")

# Bulutdagi vaqtinchalik xotira (Barcha sotuvlar ro'yxati)
sales_db = []

class SaleData(BaseModel):
    seller: str             # Toxirjon, Saidaxmad, Avazbek, Mavlonjon
    client_name: str        # Mijoz nomi / Ob'ekt
    lift_info: str          # Masalan: "7/7/7, 1000kg"
    factory_price: float    # Prayst narxi
    montage_price: float = 1200.0
    has_karkaz: bool        # True / False
    selling_price: float    # Sotuv narxi
    advance_payment: float  # Avans
    delivery_days: int      # 10, 20, 30 kun

# 1. Mobil ilovadan sotuvni qabul qilish
@app.post("/add_sale")
def add_sale(sale: SaleData):
    try:
        karkaz_price = 1500.0 if sale.has_karkaz else 0.0
        total_cost = sale.factory_price + sale.montage_price + karkaz_price
        profit = sale.selling_price - total_cost
        remaining_balance = sale.selling_price - sale.advance_payment
        current_date = datetime.now().strftime("%d.%m.%Y %H:%M")
        
        sale_entry = {
            "date": current_date,
            "seller": sale.seller,
            "client_name": sale.client_name,
            "lift_info": sale.lift_info,
            "factory_price": sale.factory_price,
            "montage_price": sale.montage_price,
            "karkaz_price": karkaz_price,
            "total_cost": total_cost,
            "selling_price": sale.selling_price,
            "profit": profit,
            "advance_payment": sale.advance_payment,
            "remaining_balance": remaining_balance,
            "delivery_days": f"{sale.delivery_days} KUN"
        }
        
        sales_db.append(sale_entry)
        return {"status": "success", "message": "Sotuv serverga saqlandi!", "profit": profit}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 2. Ofisdagi sync.py skriptiga sotuvlarni topshirish (Mana shu yo'q edi!)
@app.get("/get_sales")
def get_sales():
    return sales_db
