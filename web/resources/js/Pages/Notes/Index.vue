<template>
    <div class="m-0 p-0 bg-gray-100">
        <div class="container mx-auto p-4 bg-transparent" style="padding-top: 100px;">
            <!-- Logout Button (Top Left) -->
            <button @click="logout"
                class="absolute top-4 left-4 px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-red-400">
                Logout
            </button>

            <!-- Title and Button for Creating Notes -->
            <div class="flex justify-between items-center mb-6">
                <h1 class="text-3xl font-semibold text-gray-800">Your Notes</h1>
                <button @click="createNote"
                    class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400">
                    Create Note
                </button>
            </div>

            <!-- Notes List -->
            <div class="space-y-4">
                <div v-for="note in notes" :key="note.id"
                    class="p-8 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300">
                    <h3 class="text-xl font-semibold text-gray-700">{{ note . title }}</h3>
                    <hr>
                    <br>
                    <div class="markdown-content" v-html="renderMarkdown(note.content)"></div>
                    <div class="mt-4 flex justify-end gap-2">
                        <button @click="editNote(note)"
                            class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-400">
                            Edit
                        </button>
                        <button @click="deleteNote(note.id)"
                            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-red-400">
                            Delete
                        </button>
                    </div>
                </div>
            </div>

            <!-- Modal for Creating/Updating Notes -->
            <div v-if="modalVisible" class="fixed inset-0 flex justify-center items-center bg-black bg-opacity-50">
                <div class="bg-white p-6 rounded-lg shadow-lg max-w-lg w-full">
                    <h2 class="text-2xl font-semibold text-gray-800 mb-4">
                        {{ currentNote . id ? 'Edit Note' : 'Create Note' }}</h2>
                    <input v-model="currentNote.title" placeholder="Title"
                        class="w-full p-2 mb-4 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <textarea v-model="currentNote.content" placeholder="Content"
                        class="w-full p-2 mb-4 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                    <div class="flex justify-end gap-2">
                        <button @click="saveNote"
                            class="px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            Save
                        </button>
                        <button @click="modalVisible = false"
                            class="px-6 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-400">
                            Cancel
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import {
        marked
    } from 'marked'; // Correct import for the marked function
    import axios from 'axios';
    import {
        ref
    } from 'vue';

    export default {
        props: {
            notes: Array,
        },
        setup(props) {
            const notes = ref(props.notes);
            const modalVisible = ref(false);
            const currentNote = ref({
                title: '',
                content: ''
            });
            const currentNoteId = ref(null);

            const createNote = () => {
                currentNote.value = {
                    title: '',
                    content: ''
                };
                modalVisible.value = true;
            };

            const editNote = (note) => {
                currentNote.value = {
                    ...note
                };
                currentNoteId.value = note.id;
                modalVisible.value = true;
            };

            const saveNote = () => {
                const method = currentNoteId.value ? 'put' : 'post';
                const url = currentNoteId.value ? `/notes/${currentNoteId.value}` : '/notes';
                axios[method](url, currentNote.value)
                    .then(() => {
                        modalVisible.value = false;
                        // Reload notes list
                        axios.get('/notes').then((response) => {
                            notes.value = response.data.notes;
                            window.location.reload();
                        });
                        window.location.reload();
                    });
            };

            const deleteNote = (id) => {
                axios.delete(`/notes/${id}`).then(() => {
                    // Reload notes list
                    axios.get('/notes').then((response) => {
                        notes.value = response.data.notes;
                        window.location.reload();
                    });
                    window.location.reload();
                });
            };

            const logout = () => {
                localStorage.removeItem('authToken'); // If you store the token in localStorage
                window.location.href = '/logout'; // Redirect to login page
            };

            // Render markdown content
            const renderMarkdown = (content) => {
                return marked(content); // Convert markdown to HTML
            };

            return {
                notes,
                modalVisible,
                currentNote,
                createNote,
                editNote,
                saveNote,
                deleteNote,
                logout,
                renderMarkdown // Expose the renderMarkdown function
            };
        },
    };
</script>

<style>
    /* Add some styling for the modal and notes */
    .markdown-content h1 {
        font-size: 2.5rem;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .markdown-content h2 {
        font-size: 2rem;
        font-weight: bold;
        margin-bottom: 8px;
    }

    .markdown-content h3 {
        font-size: 1.5rem;
        font-weight: bold;
        margin-bottom: 6px;
    }

    .markdown-content p {
        font-size: 1.1rem;
        line-height: 1.6;
        margin-bottom: 10px;
    }

    .markdown-content ul,
    .markdown-content ol {
        padding-left: 20px;
        margin-bottom: 10px;
    }

    .markdown-content li {
        margin-bottom: 5px;
    }

    .markdown-content blockquote {
        padding-left: 20px;
        border-left: 3px solid #ccc;
        margin: 10px 0;
        font-style: italic;
    }

    .markdown-content code {
        font-family: monospace;
        background-color: #f4f4f4;
        padding: 2px 4px;
        border-radius: 4px;
    }

    .markdown-content pre {
        background-color: #2d2d2d;
        color: #f8f8f8;
        padding: 10px;
        border-radius: 4px;
        font-size: 1rem;
        overflow-x: auto;
    }
</style>
