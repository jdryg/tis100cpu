library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- TODO: Rename inputs to more meaningful names. 
entity register_file is
  generic (WIDTH : integer := 8);
  port ( I_clk : in  STD_LOGIC;
         I_we3 : in  STD_LOGIC;
         I_ra1 : in  STD_LOGIC_VECTOR (1 downto 0);
         I_ra2 : in  STD_LOGIC_VECTOR (1 downto 0);
         I_wa3 : in  STD_LOGIC_VECTOR (1 downto 0);
         I_wd3 : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_rd1 : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_rd2 : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end register_file;

architecture Behavioral of register_file is
  -- 4 registers (NIL, ACC, BAK, TMP)
  type regstype is array (0 to 3) of STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal regs: regstype;
begin
  -- Write reg on rising edge of the clock.
  process(I_clk) begin 
    if(rising_edge(I_clk)) then 
      if(I_we3 = '1') then 
        regs(to_integer(unsigned(I_wa3))) <= I_wd3;
      end if;
    end if;
  end process;

  -- Read 2 regs asynchronously
	process(I_ra1, I_ra2) begin
    -- Check for the special NIL register in order to make sure we always read 0, 
    -- independent of the value actually written to this register.
    if(I_ra1 = "00") then 
      O_rd1 <= (others => '0');
    else 
      O_rd1 <= regs(to_integer(unsigned(I_ra1)));
    end if;

    if(I_ra2 = "00") then
      O_rd2 <= (others => '0');
    else
      O_rd2 <= regs(to_integer(unsigned(I_ra2)));
    end if;
  end process;
end Behavioral;
