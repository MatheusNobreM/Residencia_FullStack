// 1. Function that returns the bigger of two numbers
function maxOfTwo(a, b) {
  return a > b ? a : b;
}

// 2. Function to calculate power of one number raised to another
function calculatePower(base, exponent) {
    return Math.pow(base, exponent);
}

// 3. Function to calculate the factorial of a number
function calculateFactorial(n) {
    if (n < 0) return undefined;
    if (n === 0 || n === 1) return 1;
    let result = 1;
    for (let i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// 4. Function to calculate the area of a circle from its radius
function calculateCircleArea(radius) {
    return Math.PI * radius * radius;
}

// 5. Function that returns only even numbers from an array
function filterEvenNumbers(numbers) {
    return numbers.filter(num => num % 2 === 0);
}

//6. Write a function that takes an array of numbers and returns the largest number in the array.
function maiorNumero(array) {
    return Math.max(...array);
}

// 7. Write a function that generates the first n numbers in the Fibonacci sequence.
function fibonacci(n) {
    let sequencia = [0, 1];
    for (let i = 2; i < n; i++) {
        sequencia[i] = sequencia[i - 1] + sequencia[i - 2];
    }
    return sequencia.slice(0, n);
}

// 8. Write a function that counts how many vowels there are in a given string.
function contarVogais(str) {
    const vogais = str.match(/[aeiouáéíóúâêîôûãõàèìòù]/gi);
    return vogais ? vogais.length : 0;
}

// 9. Write a function that takes a number and returns whether it is even or odd.
function parOuImpar(numero) {
    return numero % 2 === 0 ? "Par" : "Ímpar";
}

// 10. Write a function that takes a string and returns that string reversed.
function inverterString(str) {
    return str.split('').reverse().join('');
}

//11. Create a function that receives two numbers and an operator (+, -, *, /) and returns the result of the operation.
function calcular(num1, num2, operador) {
    switch(operador) {
        case '+':
            return num1 + num2;
        case '-':
            return num1 - num2;
        case '*':
            return num1 * num2;
        case '/':
            return num1 / num2;
        default:
            return "Operador inválido. Use +, -, * ou /";
    }
}

//12. Create a function that validates a CPF (Brazilian format) according to the official rules.
function validarCPF(cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replace(/\D/g, '');

    // Verifica se tem 11 dígitos ou se é uma sequência repetida
    if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) {
        return false;
    }

    // Validação do primeiro dígito verificador
    let soma = 0;
    for (let i = 0; i < 9; i++) {
        soma += parseInt(cpf.charAt(i)) * (10 - i);
    }
    let resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    if (resto !== parseInt(cpf.charAt(9))) {
        return false;
    }

    // Validação do segundo dígito verificador
    soma = 0;
    for (let i = 0; i < 10; i++) {
        soma += parseInt(cpf.charAt(i)) * (11 - i);
    }
    resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    if (resto !== parseInt(cpf.charAt(10))) {
        return false;
    }

    return true;
}

// 13. Develop a function that implements a simple timer, counting seconds and displaying the result in the console.
function cronometro(segundos) {
    let contador = 0;
    const intervalo = setInterval(() => {
        console.log(`Tempo decorrido: ${contador} segundos`);
        contador++;
        if (contador > segundos) {
            clearInterval(intervalo);
            console.log("Cronômetro finalizado!");
        }
    }, 1000);
}

// Para usar: cronometro(10); // Contará até 10 segundos