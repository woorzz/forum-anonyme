export function formatDate(dateStr) {
    return new Date(dateStr).toLocaleString('fr-FR', {
      dateStyle: 'short',
      timeStyle: 'short'
    });
  }
  