library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
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
end register_file;

architecture Behavioral of register_file is
  -- 4 registers (NIL, ACC, BAK, TMP)
  type regstype is array (0 to 3) of STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  type regindextype is array (0 to 3) of integer range 0 to 3;
  signal regID: regindextype := (0, 1, 2, 3);
  signal regs: regstype := (X"0000", X"0000", X"0000", X"0000");
begin
  -- Write reg on rising edge of the clock.
  process(I_clk) begin 
    if(rising_edge(I_clk)) then 
      if(I_swp = '1') then
        regID(1) <= 3 - regID(1);
        regID(2) <= 3 - regID(2);
      end if;

      if(I_enableWrite = '1') then 
        regs(regID(to_integer(unsigned(I_dstID)))) <= I_dstData;
      end if;
    end if;
  end process;

  -- Read 2 regs 
	process(I_clk, I_srcAID, I_srcBID) begin
    -- Check for the special NIL register in order to make sure we always read 0, 
    -- independent of the value actually written to this register.
    if(I_srcAID = "00") then 
      O_srcAData <= (others => '0');
    else 
      O_srcAData <= regs(regID(to_integer(unsigned(I_srcAID))));
    end if;

    if(I_srcBID = "00") then
      O_srcBData <= (others => '0');
    else
      O_srcBData <= regs(regID(to_integer(unsigned(I_srcBID))));
    end if;
  end process;
end Behavioral;
