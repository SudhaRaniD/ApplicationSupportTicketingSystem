# from sqlalchemy import text
# from ApplicationSupportBackEnd.database import SessionLocal

# db = SessionLocal()

# result = db.execute(
#     text("SELECT * FROM tickets")
# )

# for row in result:
#     print(row)

# db.close()


from sqlalchemy import text
from ApplicationSupportBackEnd.database import SessionLocal

db = SessionLocal()

# result = db.execute(
#     text("SELECT id, title, priority, status, assigned_to FROM tickets")
# )

result = db.execute(
    text("""
        SELECT id, title, priority, status, assigned_to
        FROM tickets
        WHERE id = 2;
    """)
)

for row in result:
    print(row)

db.close()