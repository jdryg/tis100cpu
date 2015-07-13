#ifndef MicroInstruction_h
#define MicroInstruction_h

enum MIMnemonic
{
	// Register instructions
	MIM_ADD,
	MIM_SUB,
	MIM_NEG,
	MIM_SWP,
	MIM_ISUB,

	// Port instructions
	MIM_RDP,
	MIM_WRP,

	// Jumps
	MIM_JMP,
	MIM_JEZ,
	MIM_JNZ,
	MIM_JGZ,
	MIM_JLZ,
	MIM_JRO
};

enum MIDestination
{
	MID_NIL,
	MID_ACC,
	MID_BAK,
	MID_TMP,
	MID_PORT_UP,
	MID_PORT_DOWN,
	MID_PORT_LEFT,
	MID_PORT_RIGHT,
	MID_Unknown = 0xFFFFFFFF
};

enum MISource
{
	MIS_IMM,
	MIS_NIL,
	MIS_ACC,
	MIS_BAK,
	MIS_TMP,
	MIS_PORT_UP,
	MIS_PORT_DOWN,
	MIS_PORT_LEFT,
	MIS_PORT_RIGHT,
	MIS_Unknown = 0xFFFFFFFF
};

class MicroInstruction
{
public:
	MicroInstruction(MIMnemonic mnemonic, MIDestination dst, MISource srcA, MISource srcB);
	MicroInstruction(MIMnemonic mnemonic, MIDestination dst, MISource srcA, int imm);

	MIMnemonic GetMnemonic() const;
	int GetImmediate() const;
	MISource GetSourceA() const;
	MISource GetSourceB() const;
	MIDestination GetDestination() const;

	void SetImmediate(int imm);

private:
	MIMnemonic m_Mnemonic;
	MIDestination m_Dst;
	MISource m_SrcA;
	MISource m_SrcB;
	int m_Immediate;
};

//////////////////////////////////////////////////////////////////////////
// Inline functions...
//
inline MIMnemonic MicroInstruction::GetMnemonic() const
{
	return m_Mnemonic;
}

inline int MicroInstruction::GetImmediate() const
{
	return m_Immediate;
}

inline void MicroInstruction::SetImmediate(int imm)
{
	m_Immediate = imm;
}

inline MISource MicroInstruction::GetSourceA() const
{
	return m_SrcA;
}

inline MISource MicroInstruction::GetSourceB() const
{
	return m_SrcB;
}

inline MIDestination MicroInstruction::GetDestination() const
{
	return m_Dst;
}

#endif
