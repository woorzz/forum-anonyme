import { mount } from '@vue/test-utils';
import Index from '../pages/index.vue';

describe('Page Thread', () => {
  it('show title init', () => {
    const wrapper = mount(Index);
    expect(wrapper.text()).toContain('Init repo thread');
  });
});
