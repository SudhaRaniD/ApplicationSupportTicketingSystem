from pydantic import BaseModel, Field
from typing import Literal
from datetime import datetime


class TicketCreate(BaseModel):
    title: str = Field(min_length=3, max_length=100)
    description: str = Field(min_length=5, max_length=500)
    priority: Literal["Low", "Medium", "High", "Critical"]
    status: Literal["Open", "In Progress", "Resolved", "Closed"]
    assigned_to: str | None = None   #Assign Ticket to support
    category: Literal[
    "Application",
    "Database",
    "Network",
    "Access",
    "Infrastructure",
    "Other"
] = "Application"
    due_date: datetime | None = None

class TicketUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    priority: Literal["Low", "Medium", "High", "Critical"] | None = None
    status: Literal["Open", "In Progress", "Resolved", "Closed"] | None = None
    assigned_to: str | None = None
    category: Literal[
    "Application",
    "Database",
    "Network",
    "Access",
    "Infrastructure",
    "Other"
] | None = None
    due_date: datetime | None = None
    
# Ticket Id should be created automatically
class Ticket(TicketCreate):
    id: int