from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime

app = FastAPI(title="SPACE-S Lift Serveri")

sales_db = []

class SaleData(BaseModel):
    seller: str             
    client_name: str        
    lift_info: str          
    factory_price: float    
    has_karkaz: bool        
    selling_price: float    
    advance_payment: float  
    delivery_days: int = 30     

@app.post("/add_sale")
def add_sale(sale: SaleData):
    try:
        karkaz_price = 1500.0 if sale.has_karkaz else 0.0
        total_cost = sale.factory_price + karkaz_price
        profit = sale.selling_price - total_cost
        remaining_balance = sale.selling_price - sale.advance_payment
        current_date = datetime.now().strftime("%d.%m.%Y %H:%M")
        
        sale_entry = {
            "id": len(sales_db) + 1,
            "date": current_date,
            "seller": sale.seller,
            "client_name": sale.client_name,
            "lift_info": sale.lift_info,
            "factory_price": sale.factory_price,
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

@app.get("/get_sales")
def get_sales():
    return sales_db

@app.get("/get_stats")
def get_stats():
    total_sales_count = len(sales_db)
    total_revenue = sum(s["selling_price"] for s in sales_db)
    total_profit = sum(s["profit"] for s in sales_db)
    total_advance = sum(s["advance_payment"] for s in sales_db)
    
    return {
        "count": total_sales_count,
        "revenue": total_revenue,
        "profit": total_profit,
        "advance": total_advance
    }
