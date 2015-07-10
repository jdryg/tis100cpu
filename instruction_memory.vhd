library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity instruction_memory is
  port ( I_addr  : in  STD_LOGIC_VECTOR (5 downto 0);
         O_instr : out  STD_LOGIC_VECTOR (31 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
  type IMEM is array (0 to 15) of STD_LOGIC_VECTOR (31 downto 0);
  
  -- Read only memory
  -- Sample program #1: ACC = 5 * 3
  -- Version 1 without special SWP instruction.
--  constant ROM: IMEM := (
--    -- MOV 5, ACC   # iteration_counter = 5;
--    X"80800005", -- ADD ACC, NIL, 5
--    -- SAV          # BAK = iteration_counter;
--    X"01100000", -- ADD BAK, ACC, NIL
--    -- MOV 0, ACC   # res = 0;
--    X"80800000", -- ADD ACC, NIL, 0
--    -- LOOP: ADD 3  # res += 3;
--    X"80900003", -- ADD ACC, ACC, 3
--    -- SWP          # ACC = iteration_counter; BAK = res;
--    X"01900000", -- ADD TMP, ACC, NIL
--    X"00A00000", -- ADD ACC, BAK, NIL
--    X"01300000", -- ADD BAK, TMP, NIL
--    -- SUB 1        # iteration_counter -= 1;
--    X"84900001", -- SUB ACC, ACC, 1
--    -- JEZ END      # if (iteration_counter == 0) goto END;
--    X"CC100005", -- JMP EQUAL, 5
--    -- SWP          # ACC = res; BAK = iteration_counter;
--    X"01900000", -- ADD TMP, ACC, NIL
--    X"00A00000", -- ADD ACC, BAK, NIL
--    X"01300000", -- ADD BAK, TMP, NIL
--    -- JMP LOOP     # goto LOOP;
--    X"C010FFF7", -- JMP ALWAYS, -9
--    -- END: SWP     # ACC = res (= 5 * 3)
--    X"01900000", -- ADD TMP, ACC, NIL
--    X"00A00000", -- ADD ACC, BAK, NIL
--    X"01300000"  -- ADD BAK, TMP, NIL
--  );

  -- Sample program #1: ACC = 5 * 3
  -- Version 2 with dedicated SWP instruction + last instruction flag
  constant ROM: IMEM := (
    -- MOV 5, ACC   # iteration_counter = 5;
    X"80800005", -- ADD ACC, NIL, 5
    -- SAV          # BAK = iteration_counter;
    X"01100000", -- ADD BAK, ACC, NIL
    -- MOV 0, ACC   # res = 0;
    X"80800000", -- ADD ACC, NIL, 0
    -- LOOP: ADD 3  # res += 3;
    X"80900003", -- ADD ACC, ACC, 3
    -- SWP          # ACC = iteration_counter; BAK = res;
    X"10000000", -- SWP
    -- SUB 1        # iteration_counter -= 1;
    X"84900001", -- SUB ACC, ACC, 1
    -- JEZ END      # if (iteration_counter == 0) goto END;
    X"CC100003", -- JMP EQUAL, 3
    -- SWP          # ACC = res; BAK = iteration_counter;
    X"10000000", -- SWP
    -- JMP LOOP     # goto LOOP;
    X"C010FFFB", -- JMP ALWAYS, -5
    -- END: SWP     # ACC = res (= 5 * 3)
    X"10010000", -- SWP + last instruction
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000"  -- NOP
  );

begin
  process(I_addr) begin
    O_instr <= ROM(conv_integer(I_addr));
  end process;
end Behavioral;
