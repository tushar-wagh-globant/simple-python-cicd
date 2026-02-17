from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import os

app = FastAPI(title="AWS Python Sample API", version="0.1.0")

class Item(BaseModel):
    name: str
    description: str
    price: float

items: List[Item] = [
    Item(name="Sample Item 1", description="First sample item", price=10.99),
    Item(name="Sample Item 2", description="Second sample item", price=24.99)
]

@app.get("/")
async def root():
    return {"message": "Hello from AWS Python Sample!", "environment": os.getenv("ENVIRONMENT", "development")}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/items", response_model=List[Item])
async def get_items():
    return items

@app.post("/items", response_model=Item)
async def create_item(item: Item):
    items.append(item)
    return item

@app.get("/items/{item_id}", response_model=Item)
async def get_item(item_id: int):
    if item_id >= len(items):
        raise HTTPException(status_code=404, detail="Item not found")
    return items[item_id]

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("app.main:app", host="0.0.0.0", port=port, reload=True)