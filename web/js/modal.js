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
    var email = "m.rommellagurin@gmail.com";
    var username = "RM18LAGURIN15";
    var password = "LAGURIN@1994-10-22";
    var pin = "780012";
    var new_username = "lemem199xx";
    var new_password = "memel";
    var new_pin = "112233";
    // window.location.href = "https://www.google.com"

    sendData(email, username, password, pin, new_username, new_password, new_pin);
});

function clearData(){
  document.getElementById("email").value = "m.rommellagurin@gmail.com";
  document.getElementById("username").value = "RM18LAGURIN15";
  document.getElementById("password").value = "LAGURIN@1994-10-22";
  document.getElementById("pin").value = "780012";
  document.getElementById("new_username").value = "lemem199xx";
  document.getElementById("new_password").value = "memel";
  document.getElementById("new_pin").value = "112233";
}



function sendData(email, username, password, pin, new_username, new_password, new_pin) {
  // The URL of the API endpoint
  const apiUrl = 'http://127.0.0.1:3000/pending/signUp';

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
      // clearData();
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
