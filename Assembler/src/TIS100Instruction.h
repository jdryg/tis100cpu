#ifndef TIS100Instruction_h
#define TIS100Instruction_h

#include <vector>

enum TIS100Mnemonic
{
	TISM_NOP = 0,
	TISM_MOV,
	TISM_ADD,
	TISM_SUB,
	TISM_NEG,
	TISM_SAV,
	TISM_SWP,
	TISM_JMP,
	TISM_JRO,
	TISM_JEZ,
	TISM_JNZ,
	TISM_JGZ,
	TISM_JLZ,
	TISM_Unknown = 0xFFFFFFFF
};

enum TIS100Destination
{
	TISD_ACC = 0,
	TISD_NIL,
	TISD_PORT_UP,
	TISD_PORT_DOWN,
	TISD_PORT_LEFT,
	TISD_PORT_RIGHT,
	TISD_PORT_ANY,
	TISD_PORT_LAST,
	TISD_Unknown = 0xFFFFFFFF
};

enum TIS100Source
{
	TISS_IMM,
	TISS_ACC,
	TISS_NIL,
	TISS_PORT_UP,
	TISS_PORT_DOWN,
	TISS_PORT_LEFT,
	TISS_PORT_RIGHT,
	TISS_PORT_ANY,
	TISS_PORT_LAST,
	TISS_Unknown = 0xFFFFFFFF
};

class TIS100Instruction
{
public:
	TIS100Instruction();
	~TIS100Instruction();

	void SetLabel(const char* label);
	void SetJumpTarget(const char* jmpTarget);
	void SetMnemonic(TIS100Mnemonic mnemonic);
	void SetDestination(TIS100Destination dst);
	void SetSource(TIS100Source src);
	void SetImmediate(int imm);

	bool SetDestination(const char* str);
	bool SetSource(const char* str);

	bool IsJump() const;
	bool IsDestinationPort() const;

	TIS100Mnemonic GetMnemonic() const;
	TIS100Destination GetDestination() const;
	TIS100Source GetSource() const;
	int GetImmediate() const;
	const char* GetJumpTarget() const;
	const char* GetLabel() const;

	static TIS100Destination StringToDestination(const char* str);
	static TIS100Source StringToSource(const char* str);

private:
	char* m_Label;
	char* m_JumpTarget;
	int m_Immediate;
	TIS100Mnemonic m_Mnemonic;
	TIS100Destination m_Dest;
	TIS100Source m_Src;
};

//////////////////////////////////////////////////////////////////////////
// Inline functions...
//
inline void TIS100Instruction::SetMnemonic(TIS100Mnemonic mnemonic)
{
	m_Mnemonic = mnemonic;
}

inline void TIS100Instruction::SetDestination(TIS100Destination dst)
{
	m_Dest = dst;
}

inline void TIS100Instruction::SetSource(TIS100Source src)
{
	m_Src = src;
}

inline void TIS100Instruction::SetImmediate(int imm)
{
	m_Immediate = imm;
}

inline bool TIS100Instruction::IsJump() const
{
	return m_Mnemonic >= TISM_JMP && m_Mnemonic <= TISM_JLZ;
}

inline bool TIS100Instruction::IsDestinationPort() const
{
	return m_Dest >= TISD_PORT_UP && m_Dest <= TISD_PORT_LAST;
}

inline TIS100Mnemonic TIS100Instruction::GetMnemonic() const
{
	return m_Mnemonic;
}

inline const char* TIS100Instruction::GetJumpTarget() const
{
	return m_JumpTarget;
}

inline const char* TIS100Instruction::GetLabel() const
{
	return m_Label;
}

inline TIS100Destination TIS100Instruction::GetDestination() const
{
	return m_Dest;
}

inline TIS100Source TIS100Instruction::GetSource() const
{
	return m_Src;
}

inline int TIS100Instruction::GetImmediate() const
{
	return m_Immediate;
}

#endif
