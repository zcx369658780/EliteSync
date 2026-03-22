from collections import defaultdict
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from app.db import get_db
from app.deps import current_user
from app.models.entities import User, Message
from app.schemas.api import MessageReq

router = APIRouter(prefix="/api/v1/messages", tags=["chat"])


class ConnectionManager:
    def __init__(self):
        self.connections: dict[int, list[WebSocket]] = defaultdict(list)

    async def connect(self, uid: int, ws: WebSocket):
        await ws.accept()
        self.connections[uid].append(ws)

    def disconnect(self, uid: int, ws: WebSocket):
        if ws in self.connections[uid]:
            self.connections[uid].remove(ws)

    async def push(self, uid: int, payload: dict):
        for ws in self.connections[uid]:
            await ws.send_json(payload)


manager = ConnectionManager()


def room_id(a: int, b: int) -> str:
    x, y = sorted([a, b])
    return f"{x}_{y}"


@router.post("")
async def send_message(req: MessageReq, user: User = Depends(current_user), db: Session = Depends(get_db)):
    rid = room_id(user.id, req.receiver_id)
    message = Message(room_id=rid, sender_id=user.id, receiver_id=req.receiver_id, content=req.content)
    db.add(message)
    db.commit()
    db.refresh(message)
    await manager.push(req.receiver_id, {"type": "message", "from": user.id, "content": req.content, "id": message.id})
    return {"id": message.id}


@router.post("/read/{message_id}")
def mark_read(message_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    msg = db.get(Message, message_id)
    if msg and msg.receiver_id == user.id:
        msg.is_read = True
        db.commit()
    return {"ok": True}


@router.websocket("/ws/{user_id}")
async def ws_chat(ws: WebSocket, user_id: int):
    await manager.connect(user_id, ws)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(user_id, ws)
