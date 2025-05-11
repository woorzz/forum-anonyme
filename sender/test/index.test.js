import { mount } from '@vue/test-utils';
import Index from '../pages/index.vue';

describe('Page Render', () => {
  it('show title init', () => {
    const wrapper = mount(Index);
    expect(wrapper.text()).toContain('Init repo sender');
  });
});
