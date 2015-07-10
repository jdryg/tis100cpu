LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY instruction_decoder_tb IS
END instruction_decoder_tb;
 
ARCHITECTURE behavior OF instruction_decoder_tb IS 
  -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT instruction_decoder
    PORT(
      I_instr        : IN  std_logic_vector(31 downto 0);
      O_dst          : OUT  std_logic_vector(2 downto 0);
      O_srcA         : OUT  std_logic_vector(2 downto 0);
      O_srcB         : OUT  std_logic_vector(1 downto 0);
      O_imm          : OUT  std_logic_vector(15 downto 0);
      O_aluOp        : OUT  std_logic_vector(1 downto 0);
      O_srcA_isPort  : OUT  std_logic;
      O_dst_isPort   : OUT  std_logic;
      O_enableWrite  : OUT  std_logic;
      O_containsIMM  : OUT  std_logic;
      O_isJmp        : OUT  std_logic;
      O_jmpCondition : OUT  std_logic_vector(2 downto 0);
      O_isSWP        : OUT  std_logic
    );
  END COMPONENT;

  --Inputs
  signal I_instr : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
  signal O_dst : std_logic_vector(2 downto 0);
  signal O_srcA : std_logic_vector(2 downto 0);
  signal O_srcB : std_logic_vector(1 downto 0);
  signal O_imm : std_logic_vector(15 downto 0);
  signal O_aluOp : std_logic_vector(1 downto 0);
  signal O_srcA_isPort : std_logic;
  signal O_dst_isPort : std_logic;
  signal O_enableWrite : std_logic;
  signal O_containsIMM : std_logic;
  signal O_isJmp : std_logic;
  signal O_jmpCondition : std_logic_vector(2 downto 0);
  signal O_isSWP : std_logic;

BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: instruction_decoder PORT MAP (
    I_instr => I_instr,
    O_dst => O_dst,
    O_srcA => O_srcA,
    O_srcB => O_srcB,
    O_imm => O_imm,
    O_aluOp => O_aluOp,
    O_srcA_isPort => O_srcA_isPort,
    O_dst_isPort => O_dst_isPort,
    O_enableWrite => O_enableWrite,
    O_containsIMM => O_containsIMM,
    O_isJmp => O_isJmp,
    O_jmpCondition => O_jmpCondition,
    O_isSWP => O_isSWP
  );

  -- Stimulus process
  stim_proc: process
  begin
    I_instr <= X"80800005";
    wait for 10 ns;
    assert O_dst = "001"          report "(1) Invalid dst value" severity error;
    assert O_srcA = "000"         report "(1) Invalid srcA value" severity error;
    assert O_srcB = "00"          report "(1) Invalid srcB value" severity error;
    assert O_imm = X"0005"        report "(1) Invalid immediate operand value" severity error;
    assert O_aluOp = "00"         report "(1) Invalid ALU operation" severity error;
    assert O_srcA_isPort = '0'    report "(1) Invalid srcA_isPort flag" severity error;
    assert O_dst_isPort = '0'     report "(1) Invalid dst_isPort flag" severity error;
    assert O_enableWrite = '1'    report "(1) Invalid enableWrite flag" severity error;
    assert O_containsIMM = '1'    report "(1) Invalid containsIMM flag" severity error;
    assert O_isJmp = '0'          report "(1) Invalid isJmp flag" severity error;
    assert O_jmpCondition = "111" report "(1) Invalid jump condition" severity error;
    assert O_isSWP = '0'          report "(1) Invalid SWP flag" severity error;
    report "Finished decoding 'ADD ACC, NIL, 5'";
    
    I_instr <= X"84900001";
    wait for 10 ns;
    assert O_dst = "001"          report "(2) Invalid dst value" severity error;
    assert O_srcA = "001"         report "(2) Invalid srcA value" severity error;
    assert O_srcB = "00"          report "(2) Invalid srcB value" severity error;
    assert O_imm = X"0001"        report "(2) Invalid immediate operand value" severity error;
    assert O_aluOp = "01"         report "(2) Invalid ALU operation" severity error;
    assert O_srcA_isPort = '0'    report "(2) Invalid srcA_isPort flag" severity error;
    assert O_dst_isPort = '0'     report "(2) Invalid dst_isPort flag" severity error;
    assert O_enableWrite = '1'    report "(2) Invalid enableWrite flag" severity error;
    assert O_containsIMM = '1'    report "(2) Invalid containsIMM flag" severity error;
    assert O_isJmp = '0'          report "(2) Invalid isJmp flag" severity error;
    assert O_jmpCondition = "111" report "(2) Invalid jump condition" severity error;
    assert O_isSWP = '0'          report "(2) Invalid SWP flag" severity error;
    report "Finished decoding 'SUB ACC, ACC, 1'";

    I_instr <= X"CC100005";
    wait for 10 ns;
    assert O_dst = "000"          report "(3) Invalid dst value" severity error;
    assert O_srcA = "001"         report "(3) Invalid srcA value" severity error;
    assert O_srcB = "00"          report "(3) Invalid srcB value" severity error;
    assert O_imm = X"0005"        report "(3) Invalid immediate operand value" severity error;
    assert O_aluOp = "11"         report "(3) Invalid ALU operation" severity error;
    assert O_srcA_isPort = '0'    report "(3) Invalid srcA_isPort flag" severity error;
    assert O_dst_isPort = '0'     report "(3) Invalid dst_isPort flag" severity error;
    assert O_enableWrite = '0'    report "(3) Invalid enableWrite flag" severity error;
    assert O_containsIMM = '1'    report "(3) Invalid containsIMM flag" severity error;
    assert O_isJmp = '1'          report "(3) Invalid isJmp flag" severity error;
    assert O_jmpCondition = "011" report "(3) Invalid jump condition" severity error;
    assert O_isSWP = '0'          report "(3) Invalid SWP flag" severity error;
    report "Finished decoding 'JMP EQUAL, 5'";

    I_instr <= X"10000000";
    wait for 10 ns;
    assert O_dst = "000"          report "(3) Invalid dst value" severity error;
    assert O_srcA = "000"         report "(3) Invalid srcA value" severity error;
    assert O_srcB = "00"          report "(3) Invalid srcB value" severity error;
    assert O_imm = X"0000"        report "(3) Invalid immediate operand value" severity error;
    assert O_aluOp = "00"         report "(3) Invalid ALU operation" severity error;
    assert O_srcA_isPort = '0'    report "(3) Invalid srcA_isPort flag" severity error;
    assert O_dst_isPort = '0'     report "(3) Invalid dst_isPort flag" severity error;
    assert O_enableWrite = '1'    report "(3) Invalid enableWrite flag" severity error;
    assert O_containsIMM = '0'    report "(3) Invalid containsIMM flag" severity error;
    assert O_isJmp = '0'          report "(3) Invalid isJmp flag" severity error;
    assert O_jmpCondition = "111" report "(3) Invalid jump condition" severity error;
    assert O_isSWP = '1'          report "(3) Invalid SWP flag" severity error;
    report "Finished decoding 'SWP'";
    
    wait;
  end process;
END;
