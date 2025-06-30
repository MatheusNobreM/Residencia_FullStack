const previousOperationText = document.querySelector('#previous-operation');
const currentOperationText = document.querySelector('#current-operation');
const buttons = document.querySelectorAll('#buttons-container button');

class Calculator {
    constructor(previousOperationText, currentOperationText) {
        this.previousOperationText = previousOperationText;
        this.currentOperationText = currentOperationText;
        this.currentOperation = '';
    }

    //add digit to calculator screen
    addDigit(digit) {
        // check if current operation already has a dot
        if (digit === '.' && this.currentOperationText.innerText.includes('.')) {
            return; // ignore if there's already a dot
        }

        this.currentOperation = digit;
        this.updateScreen();
    }

    // process an operation
    processOperation(operation) {
        // Check if current value is empty
        if (this.currentOperationText.innerText === '' && operation !== 'C') {
            if (this.previousOperationText.innerText !== '') {
                // Change operation
                this.changeOperation(operation);
            }
            return;
        }
        // Get current and previous value
        let operationValue;
        const previous = +this.previousOperationText.innerText.split(' ')[0]; // Get previous value or 0 if empty
        const current = +this.currentOperationText.innerText;

        switch (operation){
            case "+":
                operationValue = previous + current;
                this.updateScreen(operationValue, operation, current, previous);
                break;
            case "-":
                operationValue = previous - current;
                this.updateScreen(operationValue, operation, current, previous);
                break;
            case "/":
                operationValue = previous / current;
                this.updateScreen(operationValue, operation, current, previous);
                break;
            case "*":
                operationValue = previous * current;
                this.updateScreen(operationValue, operation, current, previous);
                break;
            case "DEL":
                this.processDelOperation();
                break;
            case "CE":
                this.processClearOperation();
                break;
            case "C":
                this.processClearAllOperations();
                break;
            case "=":
                this.processEqualsOperator();
                break;
            default:
                return;
        }
    }
    
    processDelOperation() {
        // Delete the last digit of the current operation
        this.currentOperationText.innerText = this.currentOperationText.innerText.slice(0, -1);
    }

    processClearOperation() {
        // Clear the current operation
        this.currentOperationText.innerText = '';
    }

    processClearAllOperations() {
        // Clear all operations
        this.currentOperationText.innerText = '';
        this.previousOperationText.innerText = '';
    }

    // Process Operation
    processEqualsOperator() {
        const operation = previousOperationText.innerText.split(" ")[1];

        this.processOperation(operation);
    }

    // Change values of the calculator screen
    updateScreen(operationValue = null,
                 operation = null,
                 current = null,
                 previous = null) {

        if(operationValue === null) {
            this.currentOperationText.innerText += this.currentOperation;
        } else {
            // Check if zero, if it is just add current value
            if (previous === 0) {
                operationValue = current;
            } 
            // add current value to previous
            this.previousOperationText.innerText = `${operationValue} ${operation}`;
            this.currentOperationText.innerText = '';
        }
    }

    // Change the operation
    changeOperation(operation) {
        const operations = ['+', '-', '*', '/'];
        if (!operations.includes(operation)) {
            return; // Ignore if operation is not valid
        }
        this.previousOperationText.innerText = this.previousOperationText.innerText.slice(0,-1) + operation;
    }
    
}

const calc = new Calculator(previousOperationText, currentOperationText);

buttons.forEach(btn => {
    btn.addEventListener('click', (e) => {
        const value = e.target.innerText;
        if (+value >= 0 || value === '.') {
            calc.addDigit(value);
        } else {
            calc.processOperation(value);
        }
    });
})