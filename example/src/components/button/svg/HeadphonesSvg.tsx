import type { SvgProps } from 'react-native-svg';
import Svg, { Path } from 'react-native-svg';
import React from 'react';
import { SvgContext } from './SvgUtils';

export const HeadphonesSvg = (props: SvgProps) => {
  return (
    <SvgContext.Consumer>
      {(context) => (
        <>
          <Svg viewBox={'0 0 48 48'} {...context} {...props}>
            <Path d="M9.45 43.15q-1.95 0-3.325-1.375Q4.75 40.4 4.75 38.45V24q0-4 1.5-7.5t4.125-6.125Q13 7.75 16.5 6.225 20 4.7 24 4.7t7.5 1.525q3.5 1.525 6.125 4.15Q40.25 13 41.775 16.5 43.3 20 43.3 24v14.45q0 1.95-1.4 3.325-1.4 1.375-3.35 1.375H35.3q-2 0-3.375-1.375T30.55 38.45v-7.7q0-1.95 1.375-3.325Q33.3 26.05 35.3 26.05h3.25V24q0-6.1-4.225-10.325T24 9.45q-6.05 0-10.3 4.225Q9.45 17.9 9.45 24v2.05h3.3q1.95 0 3.325 1.375Q17.45 28.8 17.45 30.75v7.7q0 1.95-1.375 3.325Q14.7 43.15 12.75 43.15Z" />
          </Svg>
        </>
      )}
    </SvgContext.Consumer>
  );
};
