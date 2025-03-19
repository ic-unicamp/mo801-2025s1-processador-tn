# Projeto de um processador RISC-V multiciclo

Nesse projeto, os alunos desenvolverão um processador RISC-V simples multiciclo. A intenção principal é dominar questões básicas do desenvolvimento de hardware, como a definição de um conjunto de instruções, a implementação da máquina de estados de um processador multiciclo e a verificação do funcionamento do processador.

## Objetivos

1. Implementar um processador RISC-V simples multiciclo em Verilog sintetizável. 
2. Implementar um conjunto de testes para verificar o funcionamento do processador.
3. Executar programas implementados em C no processador.

## Especificação

Seu processador deve implementar as instruções RV32I, que é o conjunto mais simples de instruções RISC-V. A implementação deve ser multiciclo, ou seja, cada instrução pode levar um número diferente de ciclos de clock para ser executada. Você pode se inspirar na implementação multiciclo do livro "Computer Organization and Design" de David Patterson e John Hennessy.

Você pode utilizar um toolchain pronto ou montar o seu próprio toolchain ([dica de geração](https://github.com/riscv-collab/riscv-gnu-toolchain)). Alternativamente, para esse primeiro trabalho, você pode utilizar um [montador online](https://riscvasm.lucasteske.dev) (existem outros, fique à vontade para utilizar o que achar mais conveniente).

Como método de encerramento do programa, você pode utilizar a instrução *ebreak*, que encerra o simulador.

Seu código deve ser sintetizávelvel, isso significa que deve ser possível gerar um circuito lógico a partir do seu código. A verificação será feita através do iverilog.

## Algumas informações extras

* Você pode criar novos arquivos, o script de execução está configurado para compilar todos os arquivos .v presentes no diretório.
* Vocë pode criar novos testes, utilize a nomenclatura dos arquivos da pasta *test*: Crie um arquivo testeNN.mem que contém o mapa de memória com as instruções a executar e os dados necessários; Crie um arquivo chamado saidaNN.ok que contém a saída experada do teste. O script run-all.sh irá executar cada um dos testes e também comparar com o arquivo de saída esperada.
* Seu código está sendo simulado com o iverilog. É importante que seu código seja sintetizável.
* Leia o arquivo de testbench (tb.v) para entender o funcionamento do teste, veja os comentários do arquivo. Em especial, merecem destaque: 1) Toda simulação começa com um reset; 2) A simulação pode parar se forem alcançadas 4000 unidades de tempo (2000 ciclos de clock) ou se a instrução *ebreak* for executada ou se for feito algum acesso à posição de memória 4092, que é a última palavra existente na memória declarada. Qualquer um desses métodos é suficiente para encerrar a simulação.
* O testbench também monitora todos os acessos à memória que tiverem o bit 11 do endereço com valor 1. Esses acessos são impressos na tela.

## Entrega

Você deve entregar o seu projeto através do Github Classroom, bastando fazer um *commit* e *push* do seu código. os testes serão executados automaticamente. A data limite para entrega é o último dia do mês.

Seu código será avaliado com mais testes do que os que estão dispnoíveis aqui.
