const dropdown = document.querySelector('.dropdown');
const btn = dropdown.querySelector('.dropdown-btn');
const content = dropdown.querySelector('.dropdown-content');
const hiddenInput = document.getElementById('region');

btn.addEventListener('click', () => {
    content.style.display = content.style.display === 'block' ? 'none' : 'block';
});

content.querySelectorAll('div[data-value]').forEach(option => {
    option.addEventListener('click', () => {
        hiddenInput.value = option.dataset.value;
        btn.textContent = option.children[0].textContent + " (" + option.dataset.value + ")";
        content.style.display = 'none';
        dropdownBtn.style.color = "#000"; // text turns black after selection
    });
});

document.addEventListener('click', event => {
    if (!dropdown.contains(event.target)) content.style.display = 'none';
});


// Optional: reset placeholder if needed
    hiddenInput.addEventListener("change", () => {
        if (!hiddenInput.value) {
            dropdownBtn.textContent = dropdownBtn.dataset.placeholder;
            dropdownBtn.style.color = "#888"; // gray color for placeholder
        }
});
