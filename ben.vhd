-- TIS-100 16-bit Basic Execution Node (BEN)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ben is
  Generic (PROGRAM_FILENAME : string := "unknown.prg");
  Port ( I_clk, I_reset : in  STD_LOGIC;
         I_puw_dataValid : in  STD_LOGIC;
         I_pdw_dataValid : in  STD_LOGIC;
         I_plw_dataValid : in  STD_LOGIC;
         I_prw_dataValid : in  STD_LOGIC;
         I_pur_dataValid : in  STD_LOGIC;
         I_pdr_dataValid : in  STD_LOGIC;
         I_plr_dataValid : in  STD_LOGIC;
         I_prr_dataValid : in  STD_LOGIC;
         I_pur_data : in  STD_LOGIC_VECTOR (15 downto 0);
         I_pdr_data : in  STD_LOGIC_VECTOR (15 downto 0);
         I_plr_data : in  STD_LOGIC_VECTOR (15 downto 0);
         I_prr_data : in  STD_LOGIC_VECTOR (15 downto 0);
         O_puw_writeEnable : out  STD_LOGIC;
         O_pdw_writeEnable : out  STD_LOGIC;
         O_plw_writeEnable : out  STD_LOGIC;
         O_prw_writeEnable : out  STD_LOGIC;
         O_puw_data : out  STD_LOGIC_VECTOR (15 downto 0);
         O_pdw_data : out  STD_LOGIC_VECTOR (15 downto 0);
         O_plw_data : out  STD_LOGIC_VECTOR (15 downto 0);
         O_prw_data : out  STD_LOGIC_VECTOR (15 downto 0);
         O_pur_readEnable : out  STD_LOGIC;
         O_pdr_readEnable : out  STD_LOGIC;
         O_plr_readEnable : out  STD_LOGIC;
         O_prr_readEnable : out  STD_LOGIC);
end ben;

architecture Behavioral of ben is
  -- Intermediate signals
  signal PC, NewPC : STD_LOGIC_VECTOR (5 downto 0);
  signal opcode : STD_LOGIC_VECTOR (31 downto 0);
  signal dst, srcA : STD_LOGIC_VECTOR (2 downto 0);
  signal srcB : STD_LOGIC_VECTOR (1 downto 0);
  signal imm : STD_LOGIC_VECTOR (15 downto 0);
  signal aluOp : STD_LOGIC_VECTOR (2 downto 0);
  signal srcA_isPort, dst_isPort, enableWrite, containsIMM, isJmp : STD_LOGIC;
  signal jmpCondition : STD_LOGIC_VECTOR (2 downto 0);
  signal aluResult, regA_data, regB_data : STD_LOGIC_VECTOR (15 downto 0);
  signal readPortData : STD_LOGIC_VECTOR (15 downto 0);
  signal isReadPortDataValid : STD_LOGIC;
  signal portWriteCompleted : STD_LOGIC;
  signal isALUResultZero : STD_LOGIC;
  signal aluOpA, aluOpB : STD_LOGIC_VECTOR (15 downto 0);
  signal swpRegs, isLastInstr : STD_LOGIC;
  
  component reg 
    Generic(WIDTH: integer := 8);
    Port (
      I_clk : in  STD_LOGIC;
      I_reset : in  STD_LOGIC;
      I_dataIn : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
  end component;

  component instruction_memory is
    generic (FILENAME : string := PROGRAM_FILENAME);
    port ( I_addr  : in  STD_LOGIC_VECTOR (5 downto 0);
           O_instr : out  STD_LOGIC_VECTOR (31 downto 0));
  end component;
  
  component instruction_decoder is
    Port ( I_instr : in  STD_LOGIC_VECTOR (31 downto 0);
           O_dst : out  STD_LOGIC_VECTOR (2 downto 0);
           O_srcA : out  STD_LOGIC_VECTOR (2 downto 0);
           O_srcB : out  STD_LOGIC_VECTOR (1 downto 0);
           O_imm : out  STD_LOGIC_VECTOR (15 downto 0);
           O_aluOp: out STD_LOGIC_VECTOR (2 downto 0);
           O_srcA_isPort : out  STD_LOGIC;
           O_dst_isPort : out  STD_LOGIC;
           O_enableWrite : out  STD_LOGIC;
           O_containsIMM : out  STD_LOGIC;
           O_isJmp : out  STD_LOGIC;
           O_jmpCondition : out  STD_LOGIC_VECTOR (2 downto 0);
           O_isSWP : out STD_LOGIC;
           O_isLastInstr : out STD_LOGIC);
  end component;

  component register_file is
    generic (WIDTH : integer := 8);
    port ( I_clk : in  STD_LOGIC;
           I_swp : in  STD_LOGIC;
           I_enableWrite : in  STD_LOGIC;
           I_srcAID : in  STD_LOGIC_VECTOR (1 downto 0);
           I_srcBID : in  STD_LOGIC_VECTOR (1 downto 0);
           I_dstID : in  STD_LOGIC_VECTOR (1 downto 0);
           I_dstData : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_srcAData : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_srcBData : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
  end component;
  
  component node_port_readdec is
    port ( I_clk : in STD_LOGIC;
           I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
           I_readEnable : in  STD_LOGIC;
           O_readEnableUp : out  STD_LOGIC;
           O_readEnableDown : out  STD_LOGIC;
           O_readEnableLeft : out  STD_LOGIC;
           O_readEnableRight : out  STD_LOGIC);
  end component;

  component node_port_readmux is
    Generic (WIDTH: integer := 8);
    Port ( I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
           I_dataUp : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_dataDown : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_dataLeft : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_dataRight : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_isDataUpValid : in  STD_LOGIC;
           I_isDataDownValid : in  STD_LOGIC;
           I_isDataLeftValid : in  STD_LOGIC;
           I_isDataRightValid : in  STD_LOGIC;
           O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_isDataOutValid : out  STD_LOGIC);
  end component;

  component node_port_writedec is
    Generic (WIDTH : integer := 8);
    Port ( I_clk : in STD_LOGIC;
           I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
           I_writeEnable : in  STD_LOGIC;
           I_data : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_writeEnableUp : out  STD_LOGIC;
           O_writeEnableDown : out  STD_LOGIC;
           O_writeEnableLeft : out  STD_LOGIC;
           O_writeEnableRight : out  STD_LOGIC;
           O_dataUp : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_dataDown : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_dataLeft : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_dataRight : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
  end component;
  
  component node_port_writermux is
    Port ( I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
           I_isDataUpValid : in  STD_LOGIC;
           I_isDataDownValid : in  STD_LOGIC;
           I_isDataLeftValid : in  STD_LOGIC;
           I_isDataRightValid : in  STD_LOGIC;
           O_isDataValid : out  STD_LOGIC);
  end component;
  
  component alu is
    generic (WIDTH: integer := 8);
    port ( I_a, I_b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_op     : in  STD_LOGIC_VECTOR (2 downto 0);
           O_isZero : out STD_LOGIC;
           O_y      : buffer  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
  end component;

  component mux2 is
    generic (WIDTH: integer := 8);
    port ( I_A, I_B : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           I_Sel    : in  STD_LOGIC;
           O_Y      : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
  end component;

  component next_pc is
    Port ( I_srcA_isPort : in  STD_LOGIC;
           I_dst_isPort : in  STD_LOGIC;
           I_pr_isDataOutValid : in  STD_LOGIC;
           I_pw_isDataOutValid : in  STD_LOGIC;
           I_regB_data : in  STD_LOGIC_VECTOR (15 downto 0);
           I_imm : in  STD_LOGIC_VECTOR (15 downto 0);
           I_containsIMM : in  STD_LOGIC;
           I_isJump : in  STD_LOGIC;
           I_jmpCondition : in  STD_LOGIC_VECTOR (2 downto 0);
           I_isZero : in  STD_LOGIC;
           I_isLessThan : in  STD_LOGIC;
           I_PC : in  STD_LOGIC_VECTOR (5 downto 0);
           O_NewPC : out  STD_LOGIC_VECTOR (5 downto 0));
  end component;

begin
  -- PC register
  regPC: reg 
    generic map(WIDTH => 6) 
    port map(
      I_clk => I_clk, 
      I_reset => I_reset OR isLastInstr, -- Enhancement #2: Zero cycle jump to top
      I_dataIn => NewPC, 
      O_dataOut => PC
  );
  
  -- Instruction memory
  imem: instruction_memory 
    generic map(FILENAME => PROGRAM_FILENAME)
    port map(
      I_addr => PC, 
      O_instr => opcode
  );

  -- Instruction decoder
  idec: instruction_decoder 
    port map(
      I_instr => opcode, 
      O_dst => dst,
      O_srcA => srcA,
      O_srcB => srcB, 
      O_imm => imm, 
      O_aluOp => aluOp, 
      O_srcA_isPort => srcA_isPort, 
      O_dst_isPort => dst_isPort, 
      O_enableWrite => enableWrite, 
      O_containsIMM => containsIMM, 
      O_isJmp => isJmp, 
      O_jmpCondition => jmpCondition,
      O_isSWP => swpRegs, -- Enhancement #1: Single cycle SWP
      O_isLastInstr => isLastInstr -- Enhancement #2: Zero cycle jump to top
  );

  -- Register file
  regFile: register_file 
    generic map (WIDTH => 16) 
    port map(
      I_clk => I_clk, 
      I_swp => swpRegs, -- Enhancement #1: Single cycle SWP
      I_enableWrite => (NOT dst_isPort) AND enableWrite, 
      I_srcAID => srcA (1 downto 0), 
      I_srcBID => srcB (1 downto 0), 
      I_dstID => dst(1 downto 0), 
      I_dstData => aluResult, 
      O_srcAData => regA_data, 
      O_srcBData => regB_data
  );
  
  -- Port Reader decoder
  portReaderDecoder: node_port_readdec 
    port map(
      I_clk => I_clk,
      I_portID => srcA,
      I_readEnable => srcA_isPort AND enableWrite,
      O_readEnableUp => O_pur_readEnable,
      O_readEnableDown => O_pdr_readEnable,
      O_readEnableLeft => O_plr_readEnable,
      O_readEnableRight => O_prr_readEnable
  );

  -- Port Reader multiplexer
  portReaderMux: node_port_readmux
    generic map(WIDTH => 16)
    port map(
      I_portID => srcA,
      I_dataUp => I_pur_data,
      I_dataDown => I_pdr_data,
      I_dataLeft => I_plr_data,
      I_dataRight => I_prr_data,
      I_isDataUpValid => I_pur_dataValid,
      I_isDataDownValid => I_pdr_dataValid,
      I_isDataLeftValid => I_plr_dataValid,
      I_isDataRightValid => I_prr_dataValid,
      O_dataOut => readPortData,
      O_isDataOutValid => isReadPortDataValid
  );

  -- Port Writer decoder
  portWriterDecoder: node_port_writedec
    generic map(WIDTH => 16)
    port map(
      I_clk => I_clk,
      I_portID => dst,
      I_writeEnable => dst_isPort AND enableWrite,
      I_data => aluResult,
      O_writeEnableUp => O_puw_writeEnable,
      O_writeEnableDown => O_pdw_writeEnable,
      O_writeEnableLeft => O_plw_writeEnable,
      O_writeEnableRight => O_prw_writeEnable,
      O_dataUp => O_puw_data,
      O_dataDown => O_pdw_data,
      O_dataLeft => O_plw_data,
      O_dataRight => O_prw_data
  );
  
  -- Port Writer multiplexer
  portWriterMux: node_port_writermux
    port map(
      I_portID => dst,
      I_isDataUpValid => I_puw_dataValid,
      I_isDataDownValid => I_pdw_dataValid,
      I_isDataLeftValid => I_plw_dataValid,
      I_isDataRightValid => I_prw_dataValid,
      O_isDataValid => portWriteCompleted
  );

  -- ALU operand logic
  srcA_mux: mux2
    generic map(WIDTH => 16)
    port map(
      I_A => regA_data,
      I_B => readPortData,
      I_Sel => srcA_isPort,
      O_Y => aluOpA
  );

  srcB_mux: mux2
    generic map(WIDTH => 16)
    port map(
      I_A => regB_data,
      I_B => imm,
      I_Sel => containsIMM,
      O_Y => aluOpB
  );
  
  -- ALU
  arithmeticLogicUnit: alu
    generic map(WIDTH => 16)
    port map(
      I_a => aluOpA,
      I_b => aluOpB,
      I_op => aluOp,
      O_isZero => isALUResultZero,
      O_y => aluResult
  );
  
  -- Next PC logic  
  pcLogic: next_pc
    port map(
      I_srcA_isPort => srcA_isPort,
      I_dst_isPort => dst_isPort,
      I_pr_isDataOutValid => isReadPortDataValid,
      I_pw_isDataOutValid => portWriteCompleted,
      I_regB_data => regB_data,
      I_imm => imm,
      I_containsIMM => containsIMM,
      I_isJump => isJmp,
      I_jmpCondition => jmpCondition,
      I_isZero => isALUResultZero,
      I_isLessThan => aluResult(0),
      I_PC => PC,
      O_NewPC => NewPC
  );
end Behavioral;

