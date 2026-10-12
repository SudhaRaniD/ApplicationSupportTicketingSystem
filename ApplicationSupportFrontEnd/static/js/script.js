
// async function loadTicketStats() {
//     try {
//         const response = await fetch(
//             "http://127.0.0.1:8000/tickets-stats"
//         );

//         if (!response.ok) {
//             throw new Error("Failed to fetch ticket statistics");
//         }

//         const data = await response.json();

//         // document.getElementById("total").textContent = data.total;
//         // document.getElementById("open").textContent = data.open;
//         // document.getElementById("in_progress").textContent = data.in_progress;
//         // document.getElementById("resolved").textContent = data.resolved;
//         // document.getElementById("closed").textContent = data.closed;
//         // document.getElementById("critical").textContent = data.critical;
//         // document.getElementById("overdue").textContent = data.overdue;

//         const fields = [
//             "total",
//             "open",
//             "in_progress",
//             "resolved",
//             "closed",
//             "critical",
//             "overdue"
//         ];

//         fields.forEach(field => {
//             document.getElementById(field).textContent = data[field];
//         });

//     } catch (error) {
//         console.error("Error loading statistics:", error);
//     }
// }

// loadTicketStats();



const API_BASE_URL = "http://127.0.0.1:8000";

// ========================================
// 1. DASHBOARD - TICKET STATISTICS
// ========================================

async function loadTicketStats() {

    // Run only on the dashboard page
    if (!document.getElementById("total")) {
        return;
    }

    try {
        const response = await fetch(
            `${API_BASE_URL}/tickets-stats`
        );

        if (!response.ok) {
            throw new Error("Failed to load ticket statistics");
        }

        const data = await response.json();

        const fields = [
            "total",
            "open",
            "in_progress",
            "resolved",
            "closed",
            "critical",
            "overdue"
        ];

        fields.forEach(field => {
            const element = document.getElementById(field);

            if (element) {
                element.textContent = data[field] ?? 0;
            }
        });

    } catch (error) {
        console.error("Dashboard error:", error);
    }
}


// ========================================
// 2. TICKET LIST - DISPLAY ALL TICKETS
// ========================================

async function loadTickets() {

    console.log("loadTickets() started");

    const tableBody = document.getElementById("ticketsBody");

    console.log("Ticket table body:", tableBody);

    if (!tableBody) {
        return;
    }

    try {
        const response = await fetch(
            `${API_BASE_URL}/tickets?skip=0&limit=100`
        );

        if (!response.ok) {
            throw new Error("Failed to load tickets");
        }

        const data = await response.json();

        tableBody.innerHTML = "";

        // FastAPI returns a response containing "tickets"
        //const tickets = data.tickets;

        console.log("API response:", data);

        const tickets = Array.isArray(data)
        ? data
        : data.tickets;

        if (!Array.isArray(tickets) || tickets.length === 0) {
            showTableMessage(tableBody, "No tickets found");
            return;
        }

        tickets.forEach(ticket => {

            const row = tableBody.insertRow();

            // Make the entire row clickable
            row.style.cursor = "pointer";

            row.addEventListener("click", () => {
                window.location.href =
                    `ticket_details.html?id=${ticket.id}`;
            });

            console.log("Rows created:", tableBody.rows.length);

            const values = [
                ticket.id,
                ticket.title,
                ticket.category ?? "-",
                ticket.priority,
                ticket.status,
                ticket.assigned_to ?? "Unassigned",
                formatDate(ticket.due_date)
            ];

            values.forEach(value => {
                const cell = row.insertCell();
                cell.textContent = value;
            });

        });

    } catch (error) {
        console.error("Ticket list error:", error);

        tableBody.innerHTML = "";
        showTableMessage(tableBody, "Unable to load tickets");
    }
}


// ========================================
// 3. TICKET DETAILS - SELECTED TICKET
// ========================================

async function loadTicketDetails() {

    // Run only on ticket_details.html
    const titleElement = document.getElementById("ticketTitle");

    if (!titleElement) {
        return;
    }

    // Example URL: ticket_details.html?id=5
    const params = new URLSearchParams(
        window.location.search
    );

    const ticketId = params.get("id");

    if (!ticketId || !/^\d+$/.test(ticketId)) {
        titleElement.textContent = "Invalid ticket ID";
        return;
    }

    try {
        const response = await fetch(
            `${API_BASE_URL}/tickets/${ticketId}`
        );

        if (!response.ok) {
            throw new Error(
                `Failed to load ticket: ${response.status}`
            );
        }

        const ticket = await response.json();

        // Ticket title and description
        setText("ticketTitle", ticket.title);
        setText("ticketDescription", ticket.description);

        // Ticket information
        setText("ticketId", ticket.id);
        setText("ticketCategory", ticket.category ?? "-");
        setText("ticketPriority", ticket.priority);
        setText("ticketStatus", ticket.status);
        setText(
            "ticketAssignee",
            ticket.assigned_to ?? "Unassigned"
        );

        // Dates
        setText(
            "ticketCreated",
            formatDate(ticket.created_at)
        );

        setText(
            "ticketDue",
            formatDate(ticket.due_date)
        );

    } catch (error) {
        console.error("Ticket details error:", error);

        titleElement.textContent =
            "Unable to load ticket details";
    }
}


// ========================================
// 4. HELPER FUNCTIONS
// ========================================

// Safely update an HTML element
function setText(elementId, value) {

    const element = document.getElementById(elementId);

    if (element) {
        element.textContent = value ?? "-";
    }
}


// Format date for display
function formatDate(dateString) {

    if (!dateString) {
        return "-";
    }

    const date = new Date(dateString);

    if (Number.isNaN(date.getTime())) {
        return "-";
    }

    return date.toLocaleString("en-GB");
}


// Display a message inside the ticket table
function showTableMessage(tableBody, message) {

    const row = tableBody.insertRow();
    const cell = row.insertCell();

    cell.colSpan = 7;
    cell.textContent = message;
    cell.style.textAlign = "center";
}


// ========================================
// 5. INITIALISE PAGE
// ========================================

// Wait until HTML elements are ready
document.addEventListener("DOMContentLoaded", () => {

    loadTicketStats();

    loadTickets();

    loadTicketDetails();

});
