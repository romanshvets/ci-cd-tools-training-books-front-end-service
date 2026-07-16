function appendRow(tbody, book) {
    const row = document.createElement('tr');
    row.dataset.id = book.id;
    row.innerHTML = `
        <td>${book.id}</td>
        <td>${book.name}</td>
        <td>${book.author}</td>
        <td>${book.publishDate}</td>
        <td class="row-actions">
            <button class="edit-btn">Edit</button>
            <button class="delete-btn">Delete</button>
        </td>
    `;
    tbody.appendChild(row);
}

async function loadBooks(tbody) {
    const res = await fetch('/api/books');
    const books = await res.json();
    tbody.innerHTML = '';
    for (const book of books) {
        appendRow(tbody, book);
    }
}

import { VERSION, BUILD_TIME } from './meta.js';

document.addEventListener('DOMContentLoaded', async () => {
    document.getElementById('frontend-version').textContent = VERSION;
    document.getElementById('frontend-build-time').textContent = BUILD_TIME;
    const tbody = document.getElementById('books-tbody');

    const addDialog = document.getElementById('add-dialog');
    const addForm = document.getElementById('add-form');

    const editDialog = document.getElementById('edit-dialog');
    const editForm = document.getElementById('edit-form');

    await loadBooks(tbody);

    // --- Help ---
    const helpDialog = document.getElementById('help-dialog');
    document.getElementById('help-btn').addEventListener('click', async () => {
        const meta = await fetch('/api/meta').then(r => r.json());
        document.getElementById('backend-version').textContent = meta.version;
        document.getElementById('backend-build-time').textContent = meta.buildDate;
        helpDialog.showModal();
    });
    document.getElementById('help-ok-btn').addEventListener('click', () => helpDialog.close());

    // --- Add ---
    document.getElementById('add-btn').addEventListener('click', () => {
        addForm.reset();
        addDialog.showModal();
    });

    document.getElementById('cancel-btn').addEventListener('click', () => {
        addDialog.close();
    });

    addForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = Object.fromEntries(new FormData(addForm));
        await fetch('/api/books', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data),
        });
        addDialog.close();
        await loadBooks(tbody);
    });

    // --- Edit ---
    document.getElementById('edit-cancel-btn').addEventListener('click', () => {
        editDialog.close();
    });

    tbody.addEventListener('click', async (e) => {
        const row = e.target.closest('tr');
        if (!row) return;

        if (e.target.classList.contains('edit-btn')) {
            const cells = row.querySelectorAll('td');
            editForm.elements['name'].value = cells[1].textContent;
            editForm.elements['author'].value = cells[2].textContent;
            editForm.elements['publishDate'].value = cells[3].textContent;
            editDialog.dataset.id = row.dataset.id;
            editDialog.showModal();
        }

        if (e.target.classList.contains('delete-btn')) {
            await fetch(`/api/books/${row.dataset.id}`, { method: 'DELETE' });
            await loadBooks(tbody);
        }
    });

    editForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = Number(editDialog.dataset.id);
        const data = { id, ...Object.fromEntries(new FormData(editForm)) };
        await fetch('/api/books', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data),
        });
        editDialog.close();
        await loadBooks(tbody);
    });
});
