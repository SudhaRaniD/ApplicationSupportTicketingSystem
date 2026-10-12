#Ticket Table

from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from ApplicationSupportBackEnd.database import Base


class TicketDB(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    priority = Column(String)
    status = Column(String)
    assigned_to = Column(String, nullable=True)
    category = Column(String, nullable=True)
    due_date = Column(DateTime, nullable=True)
    
    created_at = Column(
        DateTime,
        default=datetime.now
    )

    updated_at = Column(
        DateTime,
        default=datetime.now,
        onupdate=datetime.now
    )
    