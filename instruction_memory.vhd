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
--    X"10000000", -- SWP
--    -- SUB 1        # iteration_counter -= 1;
--    X"84900001", -- SUB ACC, ACC, 1
--    -- JEZ END      # if (iteration_counter == 0) goto END;
--    X"CC100003", -- JMP EQUAL, 3
--    -- SWP          # ACC = res; BAK = iteration_counter;
--    X"10000000", -- SWP
--    -- JMP LOOP     # goto LOOP;
--    X"C010FFFB", -- JMP ALWAYS, -5
--    -- END: SWP     # ACC = res (= 5 * 3)
--    X"10010000", -- SWP + last instruction
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000"  -- NOP
--  );

  -- Sample program #2: Read UP port, double the value and write the result to the DOWN port
  -- Version 1 with dedicated port instructions (RDP, WRP)
--  constant ROM: IMEM := (
--    -- MOV UP, ACC   # ACC = a = readPort(UP);
--    X"20800000", 
--    -- ADD ACC       # ACC += ACC;
--    X"00940000",
--    -- MOV ACC, DOWN # writePort(DOWN, ACC);
--    X"24910000",
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000", -- NOP
--    X"00000000"  -- NOP
--  );

  -- Sample program #3: New single cycle port instructions (https://github.com/jdryg/tis100cpu/wiki/Sample-program-%233-(single-cyle-port-instructions))
  constant ROM: IMEM := (
    -- MOV UP, ACC   # ACC = a = readPort(UP);
    X"20800000", -- ADD ACC, UP, NIL
    -- ADD UP        # ACC += b = readPort(UP);
    X"20840000", -- ACC ACC, UP, ACC
    -- SUB UP        # ACC -= c = readPort(UP);
    X"2C840000", -- ISUB ACC, UP, ACC
    -- MOV ACC, LEFT # writePort(LEFT, ACC);
    X"25100000", -- ADD LEFT, ACC, NIL
    -- MOV UP, DOWN  # writePort(DOWN, d = readPort(UP));
    X"28810000", -- ADD DOWN, UP, NIL
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
    X"00000000", -- NOP
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
