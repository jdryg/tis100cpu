LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY instruction_memory_tb IS
END instruction_memory_tb;

ARCHITECTURE behavior OF instruction_memory_tb IS 
  constant PROGRAM_FILENAME : string := "F:\Projects\MyStuff\TIS100\Assembler\multiply.prg";

  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT instruction_memory
    GENERIC(filename : string := PROGRAM_FILENAME);
    PORT(
      I_addr : IN  std_logic_vector(5 downto 0);
      O_instr : OUT  std_logic_vector(31 downto 0)
    );
  END COMPONENT;

  --Inputs
  signal I_addr : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
  signal O_instr : std_logic_vector(31 downto 0);

BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: instruction_memory 
  GENERIC MAP (filename => PROGRAM_FILENAME)
  PORT MAP (
    I_addr => I_addr,
    O_instr => O_instr
  );

  -- Stimulus process
  stim_proc: process
  begin		
    -- insert stimulus here 
    I_addr <= "000000";
    wait for 10 ns;
    assert O_instr = X"80800005" report "Invalid instruction @ addr 0" severity error;
    
    I_addr <= "000001";
    wait for 10 ns;
    assert O_instr = X"01100000" report "Invalid instruction @ addr 1" severity error;

    I_addr <= "000100";
    wait for 10ns;
    assert O_instr = X"10000000" report "Invalid instruction @ addr 4" severity error;

    wait;
  end process;
END;
