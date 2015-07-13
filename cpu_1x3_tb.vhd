LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cpu_1x3_tb IS
END cpu_1x3_tb;

ARCHITECTURE behavior OF cpu_1x3_tb IS 

  -- Component Declaration
  component cpu_1x3 is
    generic (
      PROGRAM_00 : string := "input.prg";
      PROGRAM_01 : string := "passthrough.prg";
      PROGRAM_02 : string := "output.prg");
    port (
      I_clk : in std_logic;
      I_reset : in std_logic);
  end component;

  -- Inputs
  signal I_clk : std_logic := '0';
  signal I_reset : std_logic := '0';

  -- Clock period definitions
  constant I_clk_period : time := 10 ns;

BEGIN
  -- Component Instantiation
  uut: cpu_1x3 
    generic map (
      PROGRAM_00 => "F:\Projects\MyStuff\TIS100\Assembler\input.prg",
      PROGRAM_01 => "F:\Projects\MyStuff\TIS100\Assembler\double.prg",
      PROGRAM_02 => "F:\Projects\MyStuff\TIS100\Assembler\output.prg")
    PORT MAP(
      I_clk => I_clk,
      I_reset => I_reset);

  -- Clock process definitions
  I_clk_process: process
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

    wait;
  end process;
END;
