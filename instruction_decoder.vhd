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
         O_jmpCondition : out  STD_LOGIC_VECTOR (2 downto 0));
end instruction_decoder;

architecture Behavioral of instruction_decoder is
begin
  decode_proc: process (I_instr) begin
    O_dst <= I_instr(8 downto 6);
    O_srcA <= I_instr(11 downto 9);
    O_srcB <= I_instr(13 downto 12);
    O_imm <= I_instr(31 downto 16);
    O_containsIMM <= I_instr(0);

    -- Default values for the rest of the signals
    O_aluOp <= "00";
    O_srcA_isPort <= '0';
    O_dst_isPort <= '0';
    O_enableWrite <= '0';
    O_isJmp <= '0';
    O_jmpCondition <= "111";

    -- Depending on the instruction type, set the correct outputs.
    if (I_instr(2 downto 1) = "00") then
      -- Arithmetic instructions
      O_enableWrite <= '1';
      case I_instr(5 downto 3) is 
        when "000" => O_aluOp <= "00";
        when "001" => O_aluOp <= "01";
        when "010" => O_aluOp <= "10";
        when others => O_aluOp <= "00";
      end case;
      -- The rest of the outputs get their default value.
    elsif (I_instr (2 downto 1) = "01") then
      -- Port instruction
      O_enableWrite <= '1';
      if (I_instr(5 downto 3) = "000") then
        -- RDP
        O_srcA_isPort <= '1';
      elsif (I_instr(5 downto 3) = "001") then
        -- WRP
        O_dst_isPort <= '1';
      end if;
    elsif (I_instr (2 downto 1) = "10") then
      -- Jxx instruction
      O_isJmp <= '1';
      O_jmpCondition <= I_instr(5 downto 3);
      O_aluOp <= "11"; -- Set Less Than
    end if;
  end process;
end Behavioral;
