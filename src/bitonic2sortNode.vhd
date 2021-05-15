-------------------------------------------------------------------------------
-- Company     : Barcelona Supercomputing Center (BSC)
-- Engineer    : Daniel Jim�nez Mazure
-- *******************************************************************
-- File       : Bitonic_Network.vhd
-- Author     : $Autor: dasjimaz@gmail.com $
-- Date       : $Date: 2021-05-06 $
-- Revisions  : $Revision: $
-- Last update: 2021-05-15
-- *******************************************************************
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bitonic Network. Merge stage:
-- 1) Sort a Bitonic sequence 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;

entity bitonic2sortNode is
  generic (
    G_ELEMENT_WIDTH : integer := 64
    );
  port (
    CLK        : in  std_logic;
    CTRL       : in  std_logic_vector(C_NCOMP/2-1 downto 0);
    RES        : out std_logic_vector(C_NCOMP/2-1 downto 0);
    BITONIC_IN : in  t_network_array(0 to 7);
    SORTED_OUT : out t_network_array(0 to 7)
    );
end bitonic2sortNode;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of bitonic2sortNode is

  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------

  signal s_sort_node  : t_network_array(0 to 7);
  signal s2_sort_node : t_network_array(0 to 7);
  signal s3_sort_node : t_network_array(0 to 7);

  -- Mux configuration Logic
  signal muxConf1stStage : t_muxConf1x4;
  signal muxConf2ndStage : t_muxConf2x2;
  signal muxConf3rdStage : t_muxConf4x1;


begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- First Stage
  -----------------------------------------------------------------------------  
  GEN_BITONIC_1ST_STAGE : for i in 0 to 0 generate
    Inst_bitonic8elements_0_0 : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => 0,
        G_LENGTH        => 4,
        G_DIRECTION     => "RIGHT"
        )
      port map(
        CLK          => CLK,
        CTRL         => CTRL(3+i downto i+0),
        MUX_CONF     => muxConf1stStage(i),
        ELEMENTS_IN  => BITONIC_IN,
        ELEMENTS_OUT => s_sort_node
        );
  end generate GEN_BITONIC_1ST_STAGE;


-----------------------------------------------------------------------------
  -- Second Stage
  -----------------------------------------------------------------------------
  GEN_BITONIC_2ND_STAGE : for i in 0 to 1 generate
    Inst_bitonic4elements_1_i : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => 1,
        G_LENGTH        => 2,
        G_DIRECTION     => "RIGHT"
        )
      port map(
        CLK             => CLK,
        CTRL            => CTRL(2*i+5 downto 2*i+4),
        MUX_CONF        => muxConf2ndStage(i),
        ELEMENTS_IN(0)  => s_sort_node(4*i),
        ELEMENTS_IN(1)  => s_sort_node(4*i+1),
        ELEMENTS_IN(2)  => s_sort_node(4*i+2),
        ELEMENTS_IN(3)  => s_sort_node(4*i+3),
        ELEMENTS_OUT(0) => s2_sort_node(4*i),
        ELEMENTS_OUT(1) => s2_sort_node(4*i+1),
        ELEMENTS_OUT(2) => s2_sort_node(4*i+2),
        ELEMENTS_OUT(3) => s2_sort_node(4*i+3)
        );
  end generate GEN_BITONIC_2ND_STAGE;


  -----------------------------------------------------------------------------
  -- Third Stage
  -----------------------------------------------------------------------------

  GEN_BITONIC_3RD_STAGE : for i in 0 to 3 generate
    Inst_bitonic2elements_2_i : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => 0,
        G_LENGTH        => 1,
        G_DIRECTION     => "RIGHT"
        )
      port map(
        CLK             => CLK,
        CTRL            => CTRL(1*i+8 downto 1*i+8),
        MUX_CONF        => muxConf3rdStage(i),
        ELEMENTS_IN(0)  => s2_sort_node(2*i),
        ELEMENTS_IN(1)  => s2_sort_node(2*i+1),
        ELEMENTS_OUT(0) => SORTED_OUT(2*i),
        ELEMENTS_OUT(1) => SORTED_OUT(2*i+1)
        );
  end generate GEN_BITONIC_3RD_STAGE;

  -----------------------------------------------------------------------------
  -- Output RES
  -----------------------------------------------------------------------------
  RES(11 downto 8) <= muxConf3rdStage(3) & muxConf3rdStage(2) & muxConf3rdStage(1) & muxConf3rdStage(0);
  RES(7 downto 4)  <= muxConf2ndStage(1) & muxConf2ndStage(0);
  RES(3 downto 0)  <= muxConf1stStage(0);

end architecture RTL;
