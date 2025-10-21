import consumer from "channels/consumer";

const escapeHtml = (value) => {
  if (value === null || value === undefined) return "";
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
};

const escapeAttribute = (value) => {
  if (value === null || value === undefined) return "";
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
};

const titleize = (value) => {
  if (!value) return "";
  return value
    .toString()
    .replace(/_/g, " ")
    .split(/\s+/)
    .filter(Boolean)
    .map((token) => token.charAt(0).toUpperCase() + token.slice(1).toLowerCase())
    .join(" ");
};

const formatMessageContents = (contents) => {
  if (!contents) return "";
  const sanitized = escapeHtml(contents);
  return sanitized.replace(/(\r\n|\n|\r)/g, "<br>");
};

const buildAttachmentHtml = (attachment, currentUserRole) => {
  if (!attachment) return "";

  const fileId = escapeAttribute(attachment.file_id);
  const fileName = escapeHtml(attachment.file_name || "Untitled document");
  const previewUrl = escapeAttribute(attachment.preview_url || attachment.view_url || attachment.download_url || "#");
  const downloadUrl = escapeAttribute(attachment.download_url || attachment.view_url || "#");
  const extension = escapeAttribute(attachment.extension || "");
  const signUrl = escapeAttribute(attachment.sign_url || "");
  const needsTenantSignature = Boolean(attachment.tenant_signature_required);
  const needsLandlordSignature = Boolean(attachment.landlord_signature_required);

  const showTenantCTA = currentUserRole === "Tenant" && needsTenantSignature && signUrl;
  const showLandlordCTA = currentUserRole === "Landlord" && needsLandlordSignature && signUrl;

  const actions = [
    `<button type="button" class="attachment-link" data-document-preview-trigger data-preview-url="${previewUrl}" data-file-name="${fileName}">View</button>`,
    `<span aria-hidden="true" class="attachment-dot">·</span>`,
    `<a href="${downloadUrl}" class="attachment-link">Download</a>`
  ];

  if (showTenantCTA || showLandlordCTA) {
    actions.push(`<span aria-hidden="true" class="attachment-dot">·</span>`);
    actions.push(`<a href="${signUrl}" class="attachment-link attachment-link--primary">Sign as ${showTenantCTA ? "Tenant" : "Landlord"}</a>`);
  }

  return `
    <div class="message-attachment" data-attachment-id="${fileId}" data-attachment-type="${extension}">
      <div class="attachment-icon" aria-hidden="true">
        <i class="fa-solid fa-file-lines"></i>
      </div>
      <div class="attachment-body">
        <div class="attachment-name">${fileName}</div>
        <div class="attachment-actions">${actions.join(" ")}</div>
      </div>
    </div>
  `;
};

// Track if we've already scrolled on initial load for this conversation
let hasScrolledOnLoad = new Set();

document.addEventListener('turbo:load', () => {
  const messagesContainer = document.querySelector('.message-list-container'); // Correctly target the scrollable container
  const messagesList = document.getElementById('messages'); // Message list within the container

  if (messagesContainer && messagesList) {
    const conversationId = messagesList.dataset.conversationId;
    const currentUserId = messagesList.dataset.currentUserId;
    const currentUserRole = messagesList.dataset.currentUserRole;

    if (conversationId) {
      console.log(`Checking for existing subscriptions before subscribing to conversation ID: ${conversationId}`);
      
      console.log("Active subscriptions before cleanup:", consumer.subscriptions.subscriptions);

      // Unsubscribe from existing subscriptions to avoid double messages
      consumer.subscriptions.subscriptions.forEach((subscription) => {
        if (subscription.identifier.includes(`"conversation_id":"${conversationId}"`)) {
          console.log("Removing duplicate subscription:", subscription);
          consumer.subscriptions.remove(subscription);
        }
      });

      console.log("Active subscriptions after cleanup:", consumer.subscriptions.subscriptions);

      // **Check if a subscription already exists**
      const existingSubscription = consumer.subscriptions.subscriptions.find((subscription) =>
        subscription.identifier.includes(`"conversation_id":"${conversationId}"`)
      );
      
      if (!existingSubscription) {
        consumer.subscriptions.create({ channel: "MessagesChannel", conversation_id: conversationId }, {
          initialized() {
            console.log(`Initializing subscription for conversation ID: ${conversationId}`);
          },
          connected() {
            console.log(`Connected to conversation ID: ${conversationId}`);
          },
          received(data) {
            if (data.type === 'mediator_assigned') {
              const messageFormContainer = document.getElementById('new_message_form');
              if (messageFormContainer) {
                messageFormContainer.style.display = 'none';
                console.log("Mediator assigned, message input form hidden.");
              }
              return; // Stop further processing
            }

            const isSender = data.sender_id.toString() === currentUserId;
            const isRecipient = data.recipient_id.toString() === currentUserId;
            
            if (isSender || isRecipient) {
              const messageClass = isSender ? 'sent' : 'received';
              const formattedRole = titleize(data.sender_role);
              const senderName = escapeHtml(data.sender_name || (isSender ? 'You' : formattedRole || 'Participant'));
              const messageContents = formatMessageContents(data.contents);
              const attachments = Array.isArray(data.attachments) ? data.attachments : [];

              const attachmentsHtml = attachments
                .map((attachment) => buildAttachmentHtml(attachment, currentUserRole))
                .filter(Boolean)
                .join('');

              const messageHtml = `
                <div class="chat-message ${messageClass}" data-message-id="${escapeAttribute(data.message_id)}" data-sender-role="${escapeAttribute(formattedRole)}" data-sender-id="${escapeAttribute(data.sender_id)}" data-current-user-id="${escapeAttribute(currentUserId)}">
                  <div class="message-bubble">
                    <div class="message-meta">
                      <span class="message-author">${senderName}</span>
                      ${formattedRole ? `<span class="message-role">${escapeHtml(formattedRole)}</span>` : ''}
                    </div>
                    ${messageContents ? `<p class="message-content">${messageContents}</p>` : ''}
                    ${attachmentsHtml ? `<div class="message-attachments">${attachmentsHtml}</div>` : ''}
                    <small class="message-timestamp">${escapeHtml(data.message_date)}</small>
                  </div>
                </div>
            `;

              messagesList.insertAdjacentHTML('beforeend', messageHtml);

              // Apply entering animation to the new message
              const newMessageElement = messagesList.lastElementChild;
              if (newMessageElement) {
                newMessageElement.classList.add('is-entering');
                newMessageElement.addEventListener('animationend', () => {
                  newMessageElement.classList.remove('is-entering');
                }, { once: true });
              }

            // Automatically scroll to the bottom instantly
              messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
          }
        });
      }
      
      // Initial scroll to bottom ONLY on first true page load
      if (!hasScrolledOnLoad.has(conversationId)) {
        hasScrolledOnLoad.add(conversationId);
        messagesContainer.classList.add("use-smooth-scroll");
        requestAnimationFrame(() => {
          messagesContainer.scrollTo({
            top: messagesContainer.scrollHeight,
            behavior: "smooth"
          });
          setTimeout(() => {
            messagesContainer.classList.remove("use-smooth-scroll");
          }, 450);
        });
      } else {
        // On subsequent turbo:load events, just jump to bottom instantly
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
      }
    } else {
      console.error("No conversation ID found in message list!");
    }
  }
});

// Clear the tracking when navigating away
document.addEventListener('turbo:before-visit', () => {
  hasScrolledOnLoad.clear();
});

document.addEventListener('turbo:load', () => {
  if (window.mediatorAssigned === true || window.mediatorAssigned === 'true') {
    const messageFormContainer = document.getElementById('new_message_form');
    if (messageFormContainer) {
      messageFormContainer.style.display = 'none';
      console.log("Mediator already assigned, message input form hidden.");
    }
  }
});
