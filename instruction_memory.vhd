library IEEE;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
  generic (filename : string := "unknown.prg");
  port ( I_addr  : in  STD_LOGIC_VECTOR (5 downto 0);
         O_instr : out  STD_LOGIC_VECTOR (31 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
begin
  process is 
    file progFile: TEXT;
    variable l: line;
    variable ch: character;
    variable i, index, result: integer;
    
    type memtype is array (0 to 15) of STD_LOGIC_VECTOR (31 downto 0);
    variable ROM: memtype;
  begin
    -- Set all instructions to NOP
    for i in 0 to 15 loop
      ROM(i) := X"0000";
    end loop;

    index := 0;

    FILE_OPEN(progFile, filename, READ_MODE);
    while (not endfile(progFile)) loop
      -- Read a single line (1 instruction)
      readline(progFile, l);

      -- Build the instruction code from the individual characters.
      result := 0;

      -- Translate each character to its value
      for i in 1 to 8 loop
        read(L, ch);

        if '0' <= ch and ch <= '9' then 
          result := character'pos(ch) - character'pos('0');
        elsif 'A' <= ch and ch <= 'F' then
          result := character'pos(ch) - character'pos('A') + 10;
        else 
          report "Format error on line " & integer'image(index) severity error;
        end if;

        ROM(index)(35 - i*4 downto 32-i*4) := std_logic_vector(to_unsigned(result, 4));
      end loop;

      index := index + 1;
    end loop;

    -- Read memory
    loop
      O_instr <= ROM(to_integer(unsigned(I_addr)));
      wait on I_addr;
    end loop;
  end process;
end Behavioral;
