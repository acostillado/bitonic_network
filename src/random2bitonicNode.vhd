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
-- Description: Bitonic Network. Bitonic stage
-- 1) Create a bitonic sequence from a random input
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;

entity random2bitonicNode is
  generic (
    G_ENABLE_PIPE   : integer := 1;
    G_ELEMENT_WIDTH : integer := 64
    );
  port (
    CLK         : in  std_logic;
    CTRL_EN     : in  std_logic;
    CTRL        : in  std_logic_vector(C_NCOMP/2-1 downto 0);
    RES         : out std_logic_vector(C_NCOMP/2-1 downto 0);
    RANDOM_IN   : in  t_network_array(0 to 7);
    BITONIC_OUT : out t_network_array(0 to 7)
    );
end random2bitonicNode;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of random2bitonicNode is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant C_SORT_NETWORK_DEPTH : integer := 8;  -- log^2 (8) (8=NUM_ELEM)
  constant C_NUM_ELEMENTS       : integer := 8;

  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------

  signal s_sort_node  : t_network_array(0 to 7);
  signal s2_sort_node : t_network_array(0 to 7);
  signal s3_sort_node : t_network_array(0 to 7);

  -- Mux configuration Logic
  signal muxConf1stStage : t_muxConf4x1;
  signal muxConf2ndStage : t_muxConf2x2;
  signal muxConf3rdStage : t_muxConf4x1;


begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- FIRST STAGE
  -----------------------------------------------------------------------------
  GEN_BITONIC_1ST_STAGE : for i in 0 to 3 generate
  begin
    Inst_bitonic2elements_0_i : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => 0,
        G_LENGTH        => 1,
        G_DIRECTION     => C_DIRECTION(i mod 2)
        )
      port map(
        CLK             => CLK,
        CTRL_EN         => CTRL_EN,
        CTRL            => CTRL(i+0 downto i+0),
        MUX_CONF        => muxConf1stStage(i),
        ELEMENTS_IN(0)  => RANDOM_IN(2*i),
        ELEMENTS_IN(1)  => RANDOM_IN(2*i+1),
        ELEMENTS_OUT(0) => s_sort_node(2*i),
        ELEMENTS_OUT(1) => s_sort_node(2*i+1)
        );
  end generate GEN_BITONIC_1ST_STAGE;

  -----------------------------------------------------------------------------
  -- Second Stage
  -----------------------------------------------------------------------------

  GEN_BITONIC_2ND_STAGE : for i in 0 to 1 generate
    Inst_bitonic4elements_1_i : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => G_ENABLE_PIPE,
        G_LENGTH        => 2,
        G_DIRECTION     => C_DIRECTION(i mod 2)
        )
      port map(
        CLK             => CLK,
        CTRL_EN         => CTRL_EN,
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
  begin
    Inst_bitonic2elements_2_i : entity work.bitonicNode
      generic map(
        G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
        G_REG_OUT       => 0,
        G_LENGTH        => 1,
        G_DIRECTION     => C_DIRECTION(i/2)
        )
      port map(
        CLK             => CLK,
        CTRL_EN         => CTRL_EN,
        CTRL            => CTRL(1*i+8 downto 1*i+8),
        MUX_CONF        => muxConf3rdStage(i),
        ELEMENTS_IN(0)  => s2_sort_node(2*i),
        ELEMENTS_IN(1)  => s2_sort_node(2*i+1),
        ELEMENTS_OUT(0) => BITONIC_OUT(2*i),
        ELEMENTS_OUT(1) => BITONIC_OUT(2*i+1)
        );
  end generate GEN_BITONIC_3RD_STAGE;


  -----------------------------------------------------------------------------
  -- Output RES
  -----------------------------------------------------------------------------
  --RES <= muxConf3rdStage(0 to 3) & muxConf2ndStage(0 to 3) & muxConf1stStage(0);
  RES(3 downto 0)  <= muxConf1stStage(3) & muxConf1stStage(2) & muxConf1stStage(1) & muxConf1stStage(0);
  RES(7 downto 4)  <= muxConf2ndStage(1) & muxConf2ndStage(0);
  RES(11 downto 8) <= muxConf3rdStage(3) & muxConf3rdStage(2) & muxConf3rdStage(1) & muxConf3rdStage(0);


end architecture RTL;
