from fastapi import APIRouter
from pydantic import BaseModel
from basic import run_graph
router=APIRouter()
class Input_str(BaseModel):
    input:str
@router.post("/answer")
async def chat(user_input:Input_str):
    result = run_graph(user_input.input)
    responses = [input.content for input in result]
    return {"responses": responses}
