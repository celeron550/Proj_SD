# Controlador de Elevador - Projeto VHDL
## Projeto da terceira unidade da disciplina DCA3301.0 Sistemas Digitais-Teoria do DCA - UFRN 2025.2
### Este projeto implementa um sistema digital para controle de elevador utilizando VHDL, capaz de ser sintetizado e implementado em uma placa FPGA

## Estrutura do Projeto

- **controlador.vhd**  
  O controlador implementa a FSM definida na HLSM.
Ela opera sob a metodologia de Modelo de Dois Processos
para garantir a separção estrita entre lógica sequencial e
combinacional:

- **datapath.vhd**  
  Caminho de dados do elevador, responsável por manipular os valores dos andares e sinais auxiliares.

- **elevador_b.vhd**
  Entidade topo que instancia o registrador e a lógica combinacional, conectando todos os sinais do sistema.

## Funcionamento

O controlador implementa uma máquina de estados finitos (FSM) para gerenciar as operações do elevador:
- Recebe comandos de chamada (`call`) e informações do andar atual.
- Decide se o elevador deve subir, descer, abrir a porta ou permanecer parado.
- Controla os sinais de saída para o motor, porta e registradores de andar.

Toda a lógica combinacional é implementada sem processos ou comandos comportamentais, exceto para o registrador de estado, conforme exigido.

## Simulação e Síntese

O projeto pode ser simulado e sintetizado no Quartus II ou em outras ferramentas compatíveis com VHDL.  



