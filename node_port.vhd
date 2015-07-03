library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity node_port is
  generic (WIDTH: integer := 8);
  port ( I_clk : in  STD_LOGIC;
         I_reset : in  STD_LOGIC;
         I_writeEnable: in STD_LOGIC;
         I_readEnable: in STD_LOGIC;
         I_dataIn : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_dataOutValid : out STD_LOGIC); -- TODO: Check if this is actually needed. We can reset the O_dataOut(0) to Z or U instead.
end node_port;

architecture Behavioral of node_port is
  type state_type is (S_EMPTY, S_WAITING_READ, S_WAITING_WRITE);
  signal state: state_type;
  signal data: STD_LOGIC_VECTOR (WIDTH - 1 downto 0);
begin
  state_proc: process (I_clk, I_reset) begin
    if (I_reset = '1') then
      state <= S_EMPTY;
    elsif (rising_edge(I_clk)) then 
      -- Always reset the O_dataOutValid output. The reading node had its chance for a whole clock cycle. 
      -- Hope it's enough :)
      O_dataOutValid <= '0';

      case state is
        when S_EMPTY => 
          -- Port is EMPTY. The worst case scenario at this point is one node to write
          -- and the other to read, at the same time. Favor writes over reads (1 cycle less to complete the transaction). 
          if (I_writeEnable = '1') then
            data <= I_dataIn;
            state <= S_WAITING_READ;
          elsif (I_readEnable = '1') then
            state <= S_WAITING_WRITE;
          end if;

        when S_WAITING_READ => 
          -- There are 2 ways to end up here. 
          -- 1) The port was EMPTY and the first request was for a write.
          -- In this case the data is valid (already stored in the EMPTY state) so if there's a pending read 
          -- we can safely output the data (and set the valid bit to 1).
          -- 2) The port was EMPTY and the first request was for a read.
          -- In this case the port already got through S_WAITING_WRITE, the data is valid, so if there's still
          -- a pending read request, we can output the data and set the valid bit to 1).
          if (I_readEnable = '1') then
            O_dataOut <= data;
            O_dataOutValid <= '1';
            state <= S_EMPTY;
          end if;

        when S_WAITING_WRITE => 
          -- The only way to end up here is if a port was empty, and a node tried to read from it.
          -- It might be possible to do everything in one cycle, but in order to keep things simple
          -- I decided to delegate (is this the right word?) the read request to the corresponding state.
          -- There's a chance the reader lowered the I_readEnable bit in the meantime (it's not correct
          -- behaviour but it might happen).
          if (I_writeEnable = '1') then
            data <= I_dataIn;
            state <= S_WAITING_READ;
          end if;
      end case;
    end if;
  end process;
end Behavioral;

