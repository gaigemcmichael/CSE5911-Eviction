import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  const messagesContainer = document.getElementById('messages');

  if (messagesContainer) {
    const conversationId = messagesContainer.dataset.conversationId;
    const currentUserId = messagesContainer.dataset.currentUserId;
    const currentUserRole = messagesContainer.dataset.currentUserRole;

    if (conversationId) {
      console.log(`Subscribing to conversation ID: ${conversationId}`);
      
      // Unsubscribe from existing subscriptions to avoid double messages
      consumer.subscriptions.subscriptions.forEach((subscription) => {
        consumer.subscriptions.remove(subscription);
      });

      consumer.subscriptions.create({ channel: "MessagesChannel", conversation_id: conversationId }, {
        received(data) {
          // Remove the placeholder message if present
          const placeholder = messagesContainer.querySelector('.no-messages');
          if (placeholder) placeholder.remove();
          // Construct the message HTML with dynamic sender context
          const isSender = data.sender_id.toString() === currentUserId;
          const senderLabel = isSender ? "You" : (currentUserRole === 'Tenant' ? 'Landlord' : 'Tenant');

          const messageHtml = `
            <div class="message ${isSender ? 'sent' : 'received'}" data-message-id="${data.message_id}">
              <p><strong>${senderLabel}:</strong></p>
              <p>${data.contents}</p>
              <small>Sent on ${data.message_date}</small>
            </div>
          `;

          messagesContainer.insertAdjacentHTML('beforeend', messageHtml);
          messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }
      });
    } else {
      console.error("No conversation ID found in messages container!");
    }
  }
});
