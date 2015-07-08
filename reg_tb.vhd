LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY reg_tb IS
END reg_tb;
 
ARCHITECTURE behavior OF reg_tb IS
  constant REG_WIDTH: integer := 16;
  
  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT reg
    GENERIC(WIDTH : integer := REG_WIDTH);
    PORT(
      I_clk : IN  std_logic;
      I_reset : IN  std_logic;
      I_dataIn : IN  std_logic_vector(WIDTH-1 downto 0);
      O_dataOut : OUT  std_logic_vector(WIDTH-1 downto 0)
    );
  END COMPONENT;

  --Inputs
  signal I_clk : std_logic := '0';
  signal I_reset : std_logic := '0';
  signal I_dataIn : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');

 	--Outputs
  signal O_dataOut : std_logic_vector(REG_WIDTH-1 downto 0);

  -- Clock period definitions
  constant I_clk_period : time := 10 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  uut: reg PORT MAP (
    I_clk => I_clk,
    I_reset => I_reset,
    I_dataIn => I_dataIn,
    O_dataOut => O_dataOut
  );

  -- Clock process definitions
  I_clk_process :process
  begin
    I_clk <= '0';
    wait for I_clk_period/2;
    I_clk <= '1';
    wait for I_clk_period/2;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    I_reset <= '1';
    wait for I_clk_period;
    
    I_reset <= '0';
    I_dataIn <= X"0010";
    wait for I_clk_period;
    assert O_dataOut = X"0010" report "Wrong output." severity error;
    
    wait;
  end process;
END;
