LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
  constant ALU_SIZE : integer := 16;

  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT alu
    GENERIC (WIDTH : integer := ALU_SIZE);
    PORT(I_a, I_b : IN  std_logic_vector(WIDTH-1 downto 0);
       I_op       : IN  std_logic_vector(1 downto 0);
       O_y        : OUT  std_logic_vector(WIDTH-1 downto 0));
  END COMPONENT;

  --Inputs
  signal I_a : std_logic_vector(ALU_SIZE-1 downto 0) := (others => '0');
  signal I_b : std_logic_vector(ALU_SIZE-1 downto 0) := (others => '0');
  signal I_op : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
  signal O_y : std_logic_vector(ALU_SIZE-1 downto 0);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: alu 
    GENERIC MAP (WIDTH => ALU_SIZE)
    PORT MAP (
          I_a => I_a,
          I_b => I_b,
          I_op => I_op,
          O_y => O_y
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- Test addition (op = 00)
      I_a <= X"0001";
      I_b <= X"0002";
      I_op <= "00";
      
      wait for 100 ns;
      
      -- Test subtraction (op = 01)
      I_op <= "01";
      
      wait for 100 ns;
      
      -- Test negation (op = 10, I_b = 1)
      I_a <= X"0005";
      I_b <= X"0001";
      I_op <= "10";
      
      wait;
      
   end process;

END;
