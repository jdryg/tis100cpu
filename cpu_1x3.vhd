library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu_1x3 is
  generic (
    PROGRAM_00 : string := "input.prg";
    PROGRAM_01 : string := "passthrough.prg";
    PROGRAM_02 : string := "output.prg");
  port (
    I_clk : in std_logic;
    I_reset : in std_logic);
end cpu_1x3;

architecture Behavioral of cpu_1x3 is
  component ben is
    Generic (PROGRAM_FILENAME : string);
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
  end component;
  
  component node_port is
    generic (WIDTH: integer := 8);
    port ( I_clk : in  STD_LOGIC;
           I_reset : in  STD_LOGIC;
           I_writeEnable: in STD_LOGIC;
           I_readEnable: in STD_LOGIC;
           I_dataIn : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           O_dataOutValid : out STD_LOGIC); -- TODO: Check if this is actually needed. We can reset the O_dataOut(0) to Z or U instead.
  end component;
  
  signal inputWriteMainRead_writeEnable : STD_LOGIC := '0';
  signal inputWriteMainRead_readEnable : STD_LOGIC := '0';
  signal input_dataOut : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
  signal main_dataIn : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
  signal main_dataInValid : STD_LOGIC := '0';
  signal mainWriteOutputRead_writeEnable : STD_LOGIC := '0';
  signal mainWriteOutputRead_readEnable : STD_LOGIC := '0';
  signal main_dataOut : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
  signal output_dataIn : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
  signal output_dataInValid : STD_LOGIC := '0';

begin
  inputWriteMainRead : node_port
    generic map(WIDTH => 16)
    port map(
      I_clk => I_clk,
      I_reset => I_reset,
      I_writeEnable => inputWriteMainRead_writeEnable,
      I_readEnable => inputWriteMainRead_readEnable,
      I_dataIn => input_dataOut,
      O_dataOut => main_dataIn,
      O_dataOutValid => main_dataInValid);

  mainWriteOutputRead: node_port
    generic map(WIDTH => 16)
    port map(
      I_clk => I_clk,
      I_reset => I_reset,
      I_writeEnable => mainWriteOutputRead_writeEnable,
      I_readEnable => mainWriteOutputRead_readEnable,
      I_dataIn => main_dataOut,
      O_dataOut => output_dataIn,
      O_dataOutValid => output_dataInValid);

  -- Input BEN
  inputBEN: ben 
    generic map(PROGRAM_FILENAME => PROGRAM_00)
    port map(
      I_clk => I_clk,
      I_reset => I_reset,
      -- Read
      -- Input BENs should not read anything
      I_pur_dataValid => '0',
      I_pdr_dataValid => '0',
      I_plr_dataValid => '0',
      I_prr_dataValid => '0',
      I_pur_data => X"0000",
      I_pdr_data => X"0000",
      I_plr_data => X"0000",
      I_prr_data => X"0000",
      O_pur_readEnable => open,
      O_pdr_readEnable => open,
      O_plr_readEnable => open,
      O_prr_readEnable => open,
      -- Write
      I_puw_dataValid => '0',
      I_pdw_dataValid => main_dataInValid,
      I_plw_dataValid => '0',
      I_prw_dataValid => '0',
      O_puw_writeEnable => open,
      O_pdw_writeEnable => inputWriteMainRead_writeEnable,
      O_plw_writeEnable => open,
      O_prw_writeEnable => open,
      O_puw_data => open,
      O_pdw_data => input_dataOut,
      O_plw_data => open,
      O_prw_data => open);

  -- Main BEN
  mainBEN: ben 
    generic map(PROGRAM_FILENAME => PROGRAM_01)
    port map(
      I_clk => I_clk,
      I_reset => I_reset,
      -- Read
      I_pur_dataValid => main_dataInValid,
      I_pdr_dataValid => '0',
      I_plr_dataValid => '0',
      I_prr_dataValid => '0',
      I_pur_data => main_dataIn,
      I_pdr_data => X"0000",
      I_plr_data => X"0000",
      I_prr_data => X"0000",
      O_pur_readEnable => inputWriteMainRead_readEnable,
      O_pdr_readEnable => open,
      O_plr_readEnable => open,
      O_prr_readEnable => open,
      -- Write
      I_puw_dataValid => '0', -- Don't write to input BENs
      I_pdw_dataValid => output_dataInValid,
      I_plw_dataValid => '0', -- No left BEN
      I_prw_dataValid => '0', -- No right BEN
      O_puw_writeEnable => open, -- Don't write to input BENs
      O_pdw_writeEnable => mainWriteOutputRead_writeEnable,
      O_plw_writeEnable => open, -- No left BEN
      O_prw_writeEnable => open, -- No right BEN
      O_puw_data => open, -- Don't write to input BENs
      O_pdw_data => main_dataOut,
      O_plw_data => open, -- No left BEN
      O_prw_data => open); -- No right BEN

  -- Output BEN
  outputBEN: ben 
    generic map(PROGRAM_FILENAME => PROGRAM_02)
    port map(
      I_clk => I_clk,
      I_reset => I_reset,
      -- Read
      I_pur_dataValid => output_dataInValid,
      I_pdr_dataValid => '0',
      I_plr_dataValid => '0',
      I_prr_dataValid => '0',
      I_pur_data => output_dataIn,
      I_pdr_data => X"0000",
      I_plr_data => X"0000",
      I_prr_data => X"0000",
      O_pur_readEnable => mainWriteOutputRead_readEnable,
      O_pdr_readEnable => open,
      O_plr_readEnable => open,
      O_prr_readEnable => open,
      -- Write
      -- Output BENs should not write anything
      I_puw_dataValid => '0',
      I_pdw_dataValid => '0',
      I_plw_dataValid => '0',
      I_prw_dataValid => '0',
      O_puw_writeEnable => open,
      O_pdw_writeEnable => open,
      O_plw_writeEnable => open,
      O_prw_writeEnable => open,
      O_puw_data => open,
      O_pdw_data => open,
      O_plw_data => open,
      O_prw_data => open);
end Behavioral;

