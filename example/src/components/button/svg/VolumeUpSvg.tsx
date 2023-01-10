import type { SvgProps } from 'react-native-svg';
import Svg, { Path } from 'react-native-svg';
import React from 'react';
import { SvgContext } from './SvgUtils';

export const VolumeUpSvg = (props: SvgProps) => {
  return (
    <SvgContext.Consumer>
      {(context) => (
        <>
          <Svg viewBox={'0 0 48 48'} {...context} {...props}>
            <Path d="M31.5 41.35q-.95.35-1.725-.25Q29 40.5 29 39.45q0-.5.25-.875T30 38q4.45-1.6 7.225-5.45Q40 28.7 40 23.95t-2.775-8.6Q34.45 11.5 30 9.85q-.45-.15-.725-.575Q29 8.85 29 8.35q0-.95.8-1.55.8-.6 1.7-.25 5.45 2 8.75 6.75t3.3 10.65q0 5.9-3.3 10.65t-8.75 6.75ZM6.85 31.25q-1.05 0-1.725-.675T4.45 28.9v-9.8q0-1 .675-1.7t1.725-.7h6.35l7.75-7.75q1.15-1.1 2.6-.475Q25 9.1 25 10.6v26.75q0 1.55-1.45 2.175-1.45.625-2.6-.525l-7.75-7.75ZM28 32.85V15.1q2.9.95 4.725 3.425Q34.55 21 34.55 24q0 3.05-1.825 5.45-1.825 2.4-4.725 3.4Z" />
          </Svg>
        </>
      )}
    </SvgContext.Consumer>
  );
};
