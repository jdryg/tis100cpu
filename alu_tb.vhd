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
       I_op       : IN  std_logic_vector(2 downto 0);
       O_isZero   : OUT std_logic;
       O_y        : BUFFER  std_logic_vector(WIDTH-1 downto 0));
  END COMPONENT;

  --Inputs
  signal I_a : std_logic_vector(ALU_SIZE-1 downto 0) := (others => '0');
  signal I_b : std_logic_vector(ALU_SIZE-1 downto 0) := (others => '0');
  signal I_op : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
  signal O_isZero : std_logic;
  signal O_y : std_logic_vector(ALU_SIZE-1 downto 0);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: alu 
    GENERIC MAP (WIDTH => ALU_SIZE)
    PORT MAP (
          I_a => I_a,
          I_b => I_b,
          I_op => I_op,
          O_isZero => O_isZero,
          O_y => O_y
        );

  -- Stimulus process
  stim_proc: process
  begin		
    -- Addition
    I_op <= "000";
    
    -- Test addition of positive numbers (op = 00)
    I_a <= X"0001";
    I_b <= X"0002";
    wait for 10 ns;
    assert O_y = X"0003" report "Addition of positive numbers failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Addition of positive numbers completed";

    -- Test addition of 1 positive and 1 negative number (op = 00)
    I_a <= X"FFF7";
    I_b <= X"0009";
    wait for 10 ns;
    assert O_y = X"0000" report "Addition of 1 positive and 1 negative number failed" severity error;
    assert O_isZero = '1' report "Invalid zero flag" severity error;
    report "Addition of mixed numbers completed";

    -- Test addition of 2 negative numbers 
    I_a <= X"FFFF";
    I_b <= X"FFFE";
    wait for 10 ns;
    assert O_y = X"FFFD" report "Addition of negative numbers failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Addition of negative numbers completed";

    -- Subtraction
    I_op <= "001";
    
    -- Test subtraction of positive numbers
    I_a <= X"0001";
    I_b <= X"0002";
    wait for 10 ns;
    assert O_y = X"FFFF" report "Subtraction of positive numbers failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Subtraction of positive numbers completed";

    -- Test subtraction of 1 positive and 1 negative number (op = 00)
    I_a <= X"FFF7";
    I_b <= X"0009";
    wait for 10 ns;
    assert O_y = X"FFEE" report "Subtraction of 1 positive and 1 negative number failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Subtraction of mixed numbers completed";

    -- Test subtraction of 2 negative numbers 
    I_a <= X"FFFF";
    I_b <= X"FFFE";
    wait for 10 ns;
    assert O_y = X"0001" report "Subtraction of negative numbers failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Subtraction of negative numbers completed";

    -- Negation
    I_op <= "010";
    I_b <= X"0001";
    
    -- Test negation of positive number
    I_a <= X"0001";
    wait for 10 ns;
    assert O_y = X"FFFF" report "Negation of positive number failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Negation of positive number completed";
    
    I_a <= X"FFFE";
    wait for 10 ns;
    assert O_y = X"0002" report "Negation of negative number failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Negation of negative number completed";
    
    -- Set Less Than
    I_op <= "011";
    I_b <= X"0000";
    
    -- -1 < 0
    I_a <= X"FFFF";
    wait for 10 ns;
    assert O_y = X"0001" report "-1 < 0 failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;

    I_a <= X"0001";
    wait for 10 ns;
    assert O_y = X"0000" report "1 < 0 failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    
    I_a <= X"0000";
    wait for 10 ns;
    assert O_y = X"0000" report "0 < 0 failed" severity error;
    assert O_isZero = '1' report "Invalid zero flag" severity error;
    report "SLT tests completed";
    
    -- Inverse SUB
    I_op <= "100";
    
    I_a <= X"0005";
    I_b <= X"0003";
    wait for 10 ns;
    assert O_y = X"FFFE" report "Inverse SUB failed" severity error;
    assert O_isZero = '0' report "Invalid zero flag" severity error;
    report "Inverse SUB completed";

    wait;
  end process;
END;
