#include "MicroInstruction.h"

MicroInstruction::MicroInstruction(MIMnemonic mnemonic, MIDestination dst, MISource srcA, MISource srcB)
{
	m_Mnemonic = mnemonic;
	m_Dst = dst;
	m_SrcA = srcA;
	m_SrcB = srcB;
	m_Immediate = 0;
}

MicroInstruction::MicroInstruction(MIMnemonic mnemonic, MIDestination dst, MISource srcA, int imm)
{
	m_Mnemonic = mnemonic;
	m_Dst = dst;
	m_SrcA = srcA;
	m_SrcB = MIS_IMM;
	m_Immediate = imm;
}
