LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY node_port_tb IS
END node_port_tb;
 
ARCHITECTURE behavior OF node_port_tb IS 
  constant PORT_SIZE: integer := 16;

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT node_port
  GENERIC (WIDTH: integer := PORT_SIZE);
  PORT(
       I_clk : IN  std_logic;
       I_reset : IN  std_logic;
       I_writeEnable : IN  std_logic;
       I_readEnable : IN  std_logic;
       I_dataIn : IN  std_logic_vector(WIDTH-1 downto 0);
       O_dataOut : OUT  std_logic_vector(WIDTH-1 downto 0);
       O_dataOutValid : OUT  std_logic
      );
  END COMPONENT;

  --Inputs
  signal I_clk : std_logic := '0';
  signal I_reset : std_logic := '0';
  signal I_writeEnable : std_logic := '0';
  signal I_readEnable : std_logic := '0';
  signal I_dataIn : std_logic_vector(PORT_SIZE-1 downto 0) := (others => '0');

 	--Outputs
  signal O_dataOut : std_logic_vector(PORT_SIZE-1 downto 0);
  signal O_dataOutValid : std_logic;

  -- Clock period definitions
  constant I_clk_period : time := 10 ns;

BEGIN
 	-- Instantiate the Unit Under Test (UUT)
  uut: node_port
    GENERIC MAP (WIDTH => PORT_SIZE)
    PORT MAP (
      I_clk => I_clk,
      I_reset => I_reset,
      I_writeEnable => I_writeEnable,
      I_readEnable => I_readEnable,
      I_dataIn => I_dataIn,
      O_dataOut => O_dataOut,
      O_dataOutValid => O_dataOutValid
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
--    wait for I_clk_period/2;

    -- Reset FSM
    I_reset <= '1';
    wait for I_clk_period;
    I_reset <= '0';

    -- Write and read at the same time.
    I_writeEnable <= '1';
    I_readEnable <= '1';
    I_dataIn <= X"dead";

    -- Write should happen at this clock cycle.
    wait for I_clk_period;

    -- Disable writes and wait an additional cycle for the read.
    I_writeEnable <= '0';
    I_dataIn <= X"0000";

    wait for I_clk_period;

    -- 
    if(O_dataOutValid = '1') then
      I_readEnable <= '0';
      assert O_dataOut = X"dead" report "Wrong output data." severity error;
    end if;

    wait;
  end process;
END;
