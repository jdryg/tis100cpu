-- Added these lines on rev. 42 in order to remove the commit message saying that 
-- there is a bug in the implementation, since the bug has been fixed in the same rev.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ben_tb IS
END ben_tb;
 
ARCHITECTURE behavior OF ben_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ben
    PORT(
         I_clk : IN  std_logic;
         I_reset : IN  std_logic;
         I_puw_dataValid : IN  std_logic;
         I_pdw_dataValid : IN  std_logic;
         I_plw_dataValid : IN  std_logic;
         I_prw_dataValid : IN  std_logic;
         I_pur_dataValid : IN  std_logic;
         I_pdr_dataValid : IN  std_logic;
         I_plr_dataValid : IN  std_logic;
         I_prr_dataValid : IN  std_logic;
         I_pur_data : IN  std_logic_vector(15 downto 0);
         I_pdr_data : IN  std_logic_vector(15 downto 0);
         I_plr_data : IN  std_logic_vector(15 downto 0);
         I_prr_data : IN  std_logic_vector(15 downto 0);
         O_puw_writeEnable : OUT  std_logic;
         O_pdw_writeEnable : OUT  std_logic;
         O_plw_writeEnable : OUT  std_logic;
         O_prw_writeEnable : OUT  std_logic;
         O_puw_data : OUT  std_logic_vector(15 downto 0);
         O_pdw_data : OUT  std_logic_vector(15 downto 0);
         O_plw_data : OUT  std_logic_vector(15 downto 0);
         O_prw_data : OUT  std_logic_vector(15 downto 0);
         O_pur_readEnable : OUT  std_logic;
         O_pdr_readEnable : OUT  std_logic;
         O_plr_readEnable : OUT  std_logic;
         O_prr_readEnable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal I_clk : std_logic := '0';
   signal I_reset : std_logic := '0';
   signal I_puw_dataValid : std_logic := '0';
   signal I_pdw_dataValid : std_logic := '0';
   signal I_plw_dataValid : std_logic := '0';
   signal I_prw_dataValid : std_logic := '0';
   signal I_pur_dataValid : std_logic := '0';
   signal I_pdr_dataValid : std_logic := '0';
   signal I_plr_dataValid : std_logic := '0';
   signal I_prr_dataValid : std_logic := '0';
   signal I_pur_data : std_logic_vector(15 downto 0) := (others => '0');
   signal I_pdr_data : std_logic_vector(15 downto 0) := (others => '0');
   signal I_plr_data : std_logic_vector(15 downto 0) := (others => '0');
   signal I_prr_data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal O_puw_writeEnable : std_logic;
   signal O_pdw_writeEnable : std_logic;
   signal O_plw_writeEnable : std_logic;
   signal O_prw_writeEnable : std_logic;
   signal O_puw_data : std_logic_vector(15 downto 0);
   signal O_pdw_data : std_logic_vector(15 downto 0);
   signal O_plw_data : std_logic_vector(15 downto 0);
   signal O_prw_data : std_logic_vector(15 downto 0);
   signal O_pur_readEnable : std_logic;
   signal O_pdr_readEnable : std_logic;
   signal O_plr_readEnable : std_logic;
   signal O_prr_readEnable : std_logic;

   -- Clock period definitions
   constant I_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ben PORT MAP (
          I_clk => I_clk,
          I_reset => I_reset,
          I_puw_dataValid => I_puw_dataValid,
          I_pdw_dataValid => I_pdw_dataValid,
          I_plw_dataValid => I_plw_dataValid,
          I_prw_dataValid => I_prw_dataValid,
          I_pur_dataValid => I_pur_dataValid,
          I_pdr_dataValid => I_pdr_dataValid,
          I_plr_dataValid => I_plr_dataValid,
          I_prr_dataValid => I_prr_dataValid,
          I_pur_data => I_pur_data,
          I_pdr_data => I_pdr_data,
          I_plr_data => I_plr_data,
          I_prr_data => I_prr_data,
          O_puw_writeEnable => O_puw_writeEnable,
          O_pdw_writeEnable => O_pdw_writeEnable,
          O_plw_writeEnable => O_plw_writeEnable,
          O_prw_writeEnable => O_prw_writeEnable,
          O_puw_data => O_puw_data,
          O_pdw_data => O_pdw_data,
          O_plw_data => O_plw_data,
          O_prw_data => O_prw_data,
          O_pur_readEnable => O_pur_readEnable,
          O_pdr_readEnable => O_pdr_readEnable,
          O_plr_readEnable => O_plr_readEnable,
          O_prr_readEnable => O_prr_readEnable
        );

  -- Clock process definitions
  I_clk_process :process
  begin
    I_clk <= '0';
		wait for I_clk_period/2;
		I_clk <= '1';
		wait for I_clk_period/2;
  end process;
 
  -- UP node for sample program #2
  up_proc: process 
    variable a : integer range 0 to 15;
  begin
    a := 0;
    while (a <= 15) loop
      -- Write a to the DOWN port
      I_pur_data <= std_logic_vector(to_signed(a, I_pur_data'length));
      I_pur_dataValid <= '1';
      
      -- Wait until the read enable flag is set for this port.
      wait until O_pur_readEnable = '1';
      
      I_pur_dataValid <= '0';
      a := a + 1;
    end loop;
  end process;
  
  -- DOWN node for sample program #2
  down_proc: process
  begin
    I_pdw_dataValid <= '0';
    
    -- Wait until the write flag is set for this port.
    wait until O_pdw_writeEnable = '1';
    
    I_pdw_dataValid <= '1';
    report "Input to DOWN port is " & integer'image(to_integer(unsigned(O_pdw_data)));

    wait for I_clk_period;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    I_reset <= '1';
    wait for I_clk_period * 2;
    I_reset <= '0';

    wait;
  end process;

END;
