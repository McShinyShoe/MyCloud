<template>
    <div>
      <h1>Your Notes</h1>
      <button @click="createNote" class="btn btn-primary">Create Note</button>
      <div v-for="note in notes" :key="note.id" class="note-item">
        <h3>{{ note.title }}</h3>
        <p>{{ note.content }}</p>
        <button @click="editNote(note)" class="btn btn-secondary">Edit</button>
        <button @click="deleteNote(note.id)" class="btn btn-danger">Delete</button>
      </div>

      <!-- Modal for creating/updating notes -->
      <div v-if="modalVisible" class="modal">
        <input v-model="currentNote.title" placeholder="Title" />
        <textarea v-model="currentNote.content" placeholder="Content"></textarea>
        <button @click="saveNote" class="btn btn-primary">Save</button>
        <button @click="modalVisible = false" class="btn btn-secondary">Cancel</button>
      </div>
    </div>
  </template>

  <script>
  import { ref } from 'vue';
  import axios from 'axios';

  export default {
    props: {
      notes: Array,
    },
    setup(props) {
      const notes = ref(props.notes);
      const modalVisible = ref(false);
      const currentNote = ref({ title: '', content: '' });
      const currentNoteId = ref(null);

      const createNote = () => {
        currentNote.value = { title: '', content: '' };
        modalVisible.value = true;
      };

      const editNote = (note) => {
        currentNote.value = { ...note };
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
            });
          });
      };

      const deleteNote = (id) => {
        axios.delete(`/notes/${id}`).then(() => {
          // Reload notes list
          axios.get('/notes').then((response) => {
            notes.value = response.data.notes;
          });
        });
      };

      return {
        notes,
        modalVisible,
        currentNote,
        createNote,
        editNote,
        saveNote,
        deleteNote,
      };
    },
  };
  </script>

  <style scoped>
  /* Add some styling for the modal and notes */
  </style>
