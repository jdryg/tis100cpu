library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decoder is
  Port ( I_instr : in  STD_LOGIC_VECTOR (31 downto 0);
         O_dst : out  STD_LOGIC_VECTOR (2 downto 0);
         O_srcA : out  STD_LOGIC_VECTOR (2 downto 0);
         O_srcB : out  STD_LOGIC_VECTOR (1 downto 0);
         O_imm : out  STD_LOGIC_VECTOR (15 downto 0);
         O_aluOp: out STD_LOGIC_VECTOR (2 downto 0);
         O_srcA_isPort : out  STD_LOGIC;
         O_dst_isPort : out  STD_LOGIC;
         O_enableWrite : out  STD_LOGIC;
         O_containsIMM : out  STD_LOGIC;
         O_isJmp : out  STD_LOGIC;
         O_jmpCondition : out  STD_LOGIC_VECTOR (2 downto 0);
         O_isSWP : out STD_LOGIC;
         O_isLastInstr : out STD_LOGIC);
end instruction_decoder;

architecture Behavioral of instruction_decoder is
begin
  decode_proc: process (I_instr) begin
    O_containsIMM <= I_instr(31);
    O_dst <= I_instr(25 downto 23);
    O_srcA <= I_instr(22 downto 20);
    O_srcB <= I_instr(19 downto 18);
    O_imm <= I_instr(15 downto 0);
    O_isLastInstr <= I_instr(16);

    -- Default values for the rest of the signals
    O_aluOp <= "000";
    O_srcA_isPort <= '0';
    O_dst_isPort <= '0';
    O_enableWrite <= '0';
    O_isJmp <= '0';
    O_jmpCondition <= "111";
    O_isSWP <= '0';

    -- Depending on the instruction type, set the correct outputs.
    if (I_instr(30 downto 29) = "00") then
      -- Arithmetic instructions
      O_enableWrite <= '1';
      case I_instr(28 downto 26) is 
        when "000" => O_aluOp <= "000";
        when "001" => O_aluOp <= "001";
        when "010" => O_aluOp <= "010";
        when others => O_aluOp <= "000";
      end case;
      
      -- Special case of SWP instruction
      if(I_instr(28 downto 26) = "100") then
        O_isSWP <= '1';
      end if;
      
      -- The rest of the outputs get their default value.
    elsif (I_instr (30 downto 29) = "01") then
      -- Port instruction
      O_enableWrite <= '1';
      if (I_instr(28 downto 26) = "000") then
        -- ADD reg, port, reg/imm
        O_srcA_isPort <= '1';
      elsif (I_instr(28 downto 26) = "001") then
        -- ADD port, reg, reg/imm
        O_dst_isPort <= '1';
      elsif (I_instr(28 downto 26) = "010") then
        -- ADD port, port, reg/imm
        O_srcA_isPort <= '1';
        O_dst_isPort <= '1';
      elsif (I_instr(28 downto 26) = "011") then
        -- ISUB reg, port, reg/imm
        O_srcA_isPort <= '1';
        O_aluOp <= "100";
      end if;
    elsif (I_instr (30 downto 29) = "10") then
      -- Jxx instruction
      O_isJmp <= '1';
      O_jmpCondition <= I_instr(28 downto 26);
      O_aluOp <= "011"; -- Set Less Than
    end if;
  end process;
end Behavioral;
