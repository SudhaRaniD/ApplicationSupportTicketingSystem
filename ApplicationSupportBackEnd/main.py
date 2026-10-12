from fastapi import FastAPI, Depends, HTTPException, Query
from  fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import datetime, date
from ApplicationSupportBackEnd.tickets import Ticket, TicketCreate, TicketUpdate
from ApplicationSupportBackEnd.database import engine, SessionLocal
from ApplicationSupportBackEnd.models import Base, TicketDB

Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()

app = FastAPI(title="Application Support Ticketing System")
# Temporary ticket storage
# tickets = []
# next_ticket_id = 1
# this assumes VS Code live server on port 5500, Because  frontend may be running on a different port from FastAPI, we need to allow browser requests between them.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:5500",
        "http://localhost:5500"
    ],
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)
@app.get("/")
def home():
    return {
        "message": "Application Support Ticketing System is running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.post("/tickets")
def create_ticket(
    ticket: TicketCreate,
    db: Session = Depends(get_db)
):
    new_ticket = TicketDB(
        title=ticket.title,
        description=ticket.description,
        priority=ticket.priority,
        status=ticket.status,
        assigned_to=ticket.assigned_to,
        category=ticket.category,
    )

    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)

    return {
        "message": "Ticket created successfully",
        "ticket": new_ticket
    }

# @app.get("/tickets")
# def get_tickets(db: Session = Depends(get_db)):

#     tickets = db.query(TicketDB).all()

#     return {
#         "tickets": tickets
        
#     }

# apply filter to get ticket based on status as open in progress...and Pagination

@app.get("/tickets")
def get_tickets(
    status: str | None = None,
    priority: str | None = None,
    search: str | None = None,
    assigned_to: str | None = None,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=10, ge=1, le=100),
    category: str | None = None,    
    db: Session = Depends(get_db)
):
    query = db.query(TicketDB)

    if status:
        query = query.filter(
            TicketDB.status == status
        )
    if priority:
        query = query.filter(
            TicketDB.priority == priority
        )

    #Search by title
    if search:
        query = query.filter(
            TicketDB.title.ilike(f"%{search}%")
        )

    if assigned_to:
        query = query.filter(
            TicketDB.assigned_to == assigned_to
    )

    if category:
        query = query.filter(
            TicketDB.category == category
    )

    # tickets = query.all()
    # Count before pagination

    total = query.count()
    tickets = (
         query
        .order_by(TicketDB.created_at.desc())
        .offset(skip)
        .limit(limit)    
        .all()
    )
    return {
        "total": total,
        "skip": skip,
        "limit": limit,
        "tickets": tickets
    }
@app.get("/tickets/today")
def get_todays_tickets(
    db: Session = Depends(get_db)
):
    today = date.today()

    tickets = db.query(TicketDB).filter(
        TicketDB.created_at >= datetime.combine(
            today,
            datetime.min.time()
        )
    ).all()

    return {
        "date": today,
        "total": len(tickets),
        "tickets": tickets
    }

@app.get("/tickets/overdue")
def get_overdue_tickets(
    db: Session = Depends(get_db)
):
    current_time = datetime.now()

    tickets = db.query(TicketDB).filter(
        TicketDB.due_date < current_time,
        TicketDB.status != "Resolved",
        TicketDB.status != "Closed"
    ).all()

    return {
        "total_overdue": len(tickets),
        "tickets": tickets
    }

@app.get("/tickets/{ticket_id}")
def get_tickets(ticket_id: int,
                db: Session = Depends(get_db)
):
    """ for ticket in tickets:
        if ticket.id == ticket_id:
            return ticket """
    """ return {
        "tickets": tickets
    } """

    ticket = db.query(TicketDB).filter(
        TicketDB.id == ticket_id
    ).first()

    if ticket:
        return ticket
    #HTTP error handling
    raise HTTPException(
        status_code=404,
        detail=f"Ticket {ticket_id} not found"
    )

@app.get("/tickets-stats")
def ticket_statistics(
    db: Session = Depends(get_db)
):
    # Total tickets
    total = db.query(TicketDB).count()

    # Open tickets
    open_tickets = db.query(TicketDB).filter(
        TicketDB.status == "Open"
    ).count()

    # In Progress tickets
    in_progress = db.query(TicketDB).filter(
        TicketDB.status == "In Progress"
    ).count()

    # Resolved tickets
    resolved = db.query(TicketDB).filter(
        TicketDB.status == "Resolved"
    ).count()

    # Closed tickets
    closed = db.query(TicketDB).filter(
        TicketDB.status == "Closed"
    ).count()
    critical = db.query(TicketDB).filter(
    TicketDB.priority == "Critical"
    ).count()

    overdue = db.query(TicketDB).filter(
    TicketDB.due_date < datetime.now(),
    TicketDB.status.notin_(["Resolved", "Closed"])
    ).count() 
    return {
        "total": total,
        "open": open_tickets,
        "in_progress": in_progress,
        "resolved": resolved,
        "closed": closed,
        "critical": critical,
        "overdue": overdue
    }     
# @app.put("/tickets/{ticket_id}")
# def update_ticket(ticket_id: int, updated_ticket: Ticket):

#     for index, ticket in enumerate(tickets):

#         if ticket.id == ticket_id:
#             update_ticket_id = ticket_id
#             tickets[index] = updated_ticket

#             return {
#                 "message": "Ticket updated successfully",
#                 "ticket": updated_ticket
#             } 
        
#     return {
#         "message": "Ticket not found"
#     }

@app.put("/tickets/{ticket_id}")
def update_ticket(
    ticket_id: int,
    updated_ticket: TicketCreate,
    db: Session = Depends(get_db)
):
    ticket = db.query(TicketDB).filter(
        TicketDB.id == ticket_id
    ).first()

    if not ticket:
        return {
            "message": "Ticket not found"
        }

    ticket.title = updated_ticket.title
    ticket.description = updated_ticket.description
    ticket.priority = updated_ticket.priority
    ticket.status = updated_ticket.status
    ticket.assigned_to = updated_ticket.assigned_to

    db.commit()
    db.refresh(ticket)

    return {
        "message": "Ticket updated successfully",
        "ticket": ticket
    }

# @app.delete("/tickets/{ticket_id}")
# def delete_ticket(ticket_id: int):

#     for index, ticket in enumerate(tickets):

#         if ticket.id == ticket_id:
#             deleted_ticket = tickets.pop(index)

#             return {
#                 "message": "Ticket deleted successfully",
#                 "ticket": deleted_ticket
#             }

#     return {
#         "message": "Ticket not found"
#     }

@app.patch("/tickets/{ticket_id}")
def patch_ticket(
    ticket_id: int,
    updated_ticket: TicketUpdate,
    db: Session = Depends(get_db)
):
    ticket = db.query(TicketDB).filter(
        TicketDB.id == ticket_id
    ).first()

    if not ticket:
        raise HTTPException(
            status_code=404,
            detail="Ticket not found"
        )

    update_data = updated_ticket.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(ticket, field, value)

    db.commit()
    db.refresh(ticket)

    return {
        "message": "Ticket updated successfully",
        "ticket": ticket
    }

@app.get("/tickets-stats")
def ticket_statistics(
    db: Session = Depends(get_db)
):
    total = db.query(TicketDB).count()

    open_tickets = db.query(TicketDB).filter(
        TicketDB.status == "Open"
    ).count()

    in_progress = db.query(TicketDB).filter(
        TicketDB.status == "In Progress"
    ).count()

    resolved = db.query(TicketDB).filter(
        TicketDB.status == "Resolved"
    ).count()

    closed = db.query(TicketDB).filter(
        TicketDB.status == "Closed"
    ).count()

    return {
        "total": total,
        "open": open_tickets,
        "in_progress": in_progress,
        "resolved": resolved,
        "closed": closed
    }

@app.delete("/tickets/{ticket_id}")
def delete_ticket(
    ticket_id: int,
    db: Session = Depends(get_db)
):
    ticket = db.query(TicketDB).filter(
        TicketDB.id == ticket_id
    ).first()

    if not ticket:
        return {
            "message": "Ticket not found"
        }

    db.delete(ticket)
    db.commit()

    return {
        "message": "Ticket deleted successfully",
        "ticket_id": ticket_id
    }