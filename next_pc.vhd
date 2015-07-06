library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity next_pc is
  Port ( I_srcA_isPort : in  STD_LOGIC;
         I_dst_isPort : in  STD_LOGIC;
         I_pr_isDataOutValid : in  STD_LOGIC;
         I_pw_isDataOutValid : in  STD_LOGIC;
         I_regB_data : in  STD_LOGIC_VECTOR (15 downto 0);
         I_imm : in  STD_LOGIC_VECTOR (15 downto 0);
         I_containsIMM : in  STD_LOGIC;
         I_isJump : in  STD_LOGIC;
         I_jmpCondition : in  STD_LOGIC_VECTOR (2 downto 0);
         I_isZero : in  STD_LOGIC;
         I_isLessThan : in  STD_LOGIC;
         I_PC : in  STD_LOGIC_VECTOR (15 downto 0);
         O_NewPC : out  STD_LOGIC_VECTOR (15 downto 0));
end next_pc;

architecture Behavioral of next_pc is
  signal isReadPortReady, isWritePortReady: STD_LOGIC;
  signal jmpDelta: STD_LOGIC_VECTOR (15 downto 0);
  signal takeJump: STD_LOGIC;
begin
  srcPortProc: process (I_srcA_isPort, I_pr_isDataOutValid) begin
    isReadPortReady <= (NOT I_srcA_isPort) OR (I_srcA_isPort AND I_pr_isDataOutValid);
  end process;
  
  dstPortProc: process (I_dst_isPort, I_pw_isDataOutValid) begin
    isWritePortReady <= (NOT I_dst_isPort) OR (I_dst_isPort AND I_pw_isDataOutValid);
  end process;
  
  
  jmpDeltaProc: process (I_regB_data, I_imm, I_containsIMM) begin
    if(I_containsIMM = '1') then
      jmpDelta <= I_imm;
    else 
      jmpDelta <= I_regB_data;
    end if;
  end process;
  
  takeJumpProc: process (I_jmpCondition, I_isZero, I_isLessThan) begin
    case I_jmpCondition is
      when "000" => takeJump <= '1'; -- Unconditional jump
      when "001" => takeJump <= NOT ((I_isZero AND '1') OR (I_isLessThan AND '1')); -- JGZ
      when "010" => takeJump <= (I_isZero AND '0') OR (I_isLessThan AND '1'); -- JLZ
      when "011" => takeJump <= (I_isZero AND '1') OR (I_isLessThan AND '0'); -- JEZ
      when "100" => takeJump <= NOT (I_isZero AND '1') OR (I_isLessThan AND '0'); -- JNZ
      when others => takeJump <= '0'; -- Unknown jump condition
    end case;
  end process;
  
  newPCProc: process (I_PC, takeJump, jmpDelta, isWritePortReady, isReadPortReady) begin
    -- If this is a port instruction, wait until the port is ready.
    if(isReadPortReady = '0' OR isWritePortReady = '0') then
      O_NewPC <= I_PC;
    else
      -- Otherwise, if it's not a jump or the jump condition is false, move on to the next instruction.
      if(I_isJump = '0' OR takeJump = '0') then
        O_NewPC <= I_PC + 1;
      else
        -- Finally, this is a jump instruction and the condition is true. Jump!
        O_NewPC <= I_PC + jmpDelta; -- TODO: I hope this is a signed add.
      end if;
    end if;
  end process;
end Behavioral;

